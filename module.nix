inputs:
{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
let
  configSource = lib.fileset.toSource {
    root = ./.;
    fileset =
      map (p: lib.optional (builtins.pathExists p) p) [
        ./init.lua
        ./lua
        ./after
        ./plugin
        ./snippets
      ]
      |> lib.flatten
      |> lib.fileset.unions;
  };
in
{
  imports = [ wlib.wrapperModules.neovim ];

  options = {
    settings = {
      devMode = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = false;
        description = ''
          Enables additional development plugins.

          Setting this flag also implicitly will use an impure and hot reloadable
          config via `unwrappedConfig`. If you don't want that, set `hotReload`
          to `false`.
        '';
      };

      terminalMode = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = false;
        description = ''
          Enable features for using neovim as your terminal and terminal multiplexer.

          For gui environments this is best paired when using neovide instead
          of ghostty/kitty/wezterm/etc.
        '';
      };

      hotReload = lib.mkOption {
        type = lib.types.bool;
        default = config.settings.devMode;
        example = false;
        description = ''
          When enabled, neovim will use a mutable impure config path.
          This allows hot reloading of some settings. Defaults to the value of
          `devMode`, but the exists so it can be forced off independently of
          `devMode`.
          When disabled, an immutable pure config in the `/nix/store` will be used.
        '';
      };

      # Have neovim use immutable config from /nix/store
      wrappedConfig = lib.mkOption {
        type = lib.types.either wlib.types.stringable lib.types.luaInline;
        default = "${configSource}";
        description = "Set of lua config files loaded into the /nix/store.";
      };

      # Have neovim use raw config folder for faster prototyping
      unwrappedConfig = lib.mkOption {
        type = lib.types.nullOr (lib.types.either wlib.types.stringable lib.types.luaInline);
        default = null;
        example = ''lib.generators.mkLuaInline "vim.uv.os_homedir() .. '/dev/nix/neovim'"'';
        description = ''
          Set can impure config path to load your config from. This can also be lua, but isn't explictily required.

          This value is used when hotReload is true.'';
      };

      baseConfig = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = ''
          Specify a base neovim config to load from a wrapper extending the
          introdus neovim module.

          This allows the introdus neovim config to be loaded at runtime. This
          can point to an impure path to allow hot reloading of introdus
          config, in addition to personal config.
        '';
      };

      defaultCommand = lib.mkOption rec {
        type = lib.types.str;
        default = "luaeval('Snacks.dashboard()')";
        example = "execute('enew')";
        description = ''
          A default expression to be run when invoking bare nvim/vim/vi command
          while already nested inside a neovim terminal. The expression will be
          passed through lib.escapeShellArg.
        '';
      };

      defaultTerminalOpenStyle = lib.mkOption {
        type = lib.types.str;
        default = "split";
        example = "vsplit";
        description = "What orientation to open a file in when running vi in a nested terminal.";
      };

      neovide = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable a neovide wrapper around the generated nvim binary.";
      };

      guifont = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Font to set from external nix config.";
      };

      # extraSpecs = lib.mkOption {
      #   type = lib.types.attrsOf lib.types.any;
      #   default = { };
      #   description = "Extra specs to integrate";
      # };

      # Inform lua which top level specs are enabled
      cats = lib.mkOption {
        readOnly = true;
        type = lib.types.attrsOf lib.types.bool;
        default = lib.mapAttrs (_: v: v.enable) config.specs;
      };
    };

    nvim-lib = {
      pluginInputs = lib.mkOption {
        type = lib.types.listOf (lib.types.attrsOf wlib.types.stringable);
        # Makes plugins autobuilt from our inputs available with
        # `config.nvim-lib.neovimPlugins.<name_without_prefix>`
        default = [ inputs ];
        description = "List of inputs that may have external neovim plugin dependencies.";
      };

      neovimPlugins = lib.mkOption {
        readOnly = true;
        type = lib.types.attrsOf wlib.types.stringable;
        default = config.nvim-lib.pluginsFromPrefix "plugins-" (
          lib.foldl lib.recursiveUpdate { } config.nvim-lib.pluginInputs
        );
      };

      pluginsFromPrefix = lib.mkOption {
        type = lib.types.raw;
        readOnly = true;
        default =
          prefix: inputAttrs:
          lib.pipe inputAttrs [
            lib.attrNames
            (lib.filter (s: lib.hasPrefix prefix s))
            (map (
              input:
              let
                name = lib.removePrefix prefix input;
              in
              {
                inherit name;
                value = config.nvim-lib.mkPlugin name inputAttrs.${input};
              }
            ))
            lib.listToAttrs
          ];
      };
    };
  };

  config = {
    # Build a neovide wrapper
    hosts.neovide.nvim-host.enable = config.settings.neovide;

    settings.config_directory =
      assert ((config.settings.hotReload == false) || (config.settings.unwrappedConfig != null));
      if config.settings.hotReload then
        config.settings.unwrappedConfig
      else
        config.settings.wrappedConfig;

    settings.aliases = [
      "vi"
      "vim"
    ];

    # If run nested inside a neovim terminal, deal with it appropriately. --remote will pass args
    # to ':drop', but if no argument was specified it will error, so just run some default expression.
    # Otherwise, pass all the args through --remote. If not in nvim, just run as normal.
    runShell = [
      # bash
      ''
        # If we are nested in nvim already, and didn't provide arguments, run
        # some sane default.
        # If neovide is trying to run us, don't bother using rpc
        if ! ps -o ppid,comm -p $PPID | grep -q neovide && [[ $NVIM ]]; then
          if [ $# -eq 0 ]; then
            set -- --server $NVIM --remote-expr ${lib.escapeShellArg config.settings.defaultCommand}
          else
            set -- --server $NVIM --remote "$@"
          fi
        fi
        # This won't be set by neovide, but some terminal stuff expects it (checkhealth, etc)
        export TERM=xterm-256color
        # If the wrapper has a baseConfig path set, expose it to neovim config
        ${
          if config.settings.baseConfig != null then
            # bash
            ''
              export NVIM_BASE_CONFIG=${config.settings.baseConfig}
            ''
          else
            ""
        }
      ''
    ];

    # ============================================================================
    # CORE SPEC (always enabled — minimal bootstrap for all other specs)
    # ============================================================================
    specs.core = {
      data = with pkgs.vimPlugins; [
        lze
        lzextras
        mini-icons
        nvim-web-devicons
        plenary-nvim
        vim-repeat
      ];
      extraPackages = with pkgs; [
        fd
        ripgrep
        tree-sitter
        universal-ctags
      ];
    };

    # ============================================================================
    # ALL BELOW ARE INTRODUS PLUGINS — COMMENTED OUT BY DEFAULT
    # Uncomment the entire block to enable. Many require nixpkgs plugins;
    # some require custom flake inputs (plugins-*).
    # ============================================================================

    # ---- COMPLETION SPEC ----
    # specs.completion = {
    #   after = [ "core" ];
    #   lazy = true;
    #   data = with pkgs.vimPlugins; [
    #     blink-cmp
    #     blink-cmp-conventional-commits
    #     blink-cmp-spell
    #     colorful-menu-nvim
    #     friendly-snippets
    #     vim-snippets
    #     luasnip
    #   ];
    # };

    # ---- EDITING SPEC ----
    # specs.editing = {
    #   after = [ "core" ];
    #   lazy = true;
    #   data = with pkgs.vimPlugins; [
    #     comment-nvim
    #     cutlass-nvim
    #     indent-blankline-nvim
    #     mini-ai
    #     mini-surround
    #     resession-nvim
    #     vim-easy-align
    #     nvim-treesitter-context
    #     nvim-ts-autotag
    #     # ---- Additional from introdus (some not in nixpkgs — see below) ----
    #     # nvim-toggler     # NOT in nixpkgs — needs plugins-nvim-toggler flake input
    #     # nvim-better-n    # NOT in nixpkgs — needs plugins-nvim-better-n flake input
    #     # pick-resession   # NOT in nixpkgs — needs plugins-pick-resession flake input
    #     # treesitter-textobjects # NOT in nixpkgs — needs plugins-treesitter-textobjects flake input
    #     # vim-repeat       # already in core spec above
    #   ];
    # };

    # ---- FORMAT SPEC ----
    # specs.format = {
    #   after = [ "core" ];
    #   lazy = true;
    #   data = with pkgs.vimPlugins; [
    #     conform-nvim
    #   ];
    #   extraPackages = with pkgs; [
    #     fixjson
    #     kdlfmt
    #     shfmt
    #     shellharden
    #     nixfmt
    #     rustfmt
    #     ruff
    #     yamlfmt
    #     prettier
    #     stylua
    #   ];
    # };

    # ---- LSP SPEC ----
    specs.lsp = {
      after = [ "core" ];
      lazy = true;
      enable = config.settings.devMode;
      data = with pkgs.vimPlugins; [
        #     lazydev-nvim
        #     SchemaStore-nvim
        nvim-lspconfig
      ];

      mainInfo.nixdExtras = {
        nixpkgs = "import ${lib.cleanSource pkgs.path} {}";
        get_configs =
          lib.generators.mkLuaInline
            # lua
            ''
              function(type, path)
                  return [[import ${./nixd.nix} "${pkgs.stdenv.hostPlatform.system}" "]] .. type .. [[" ]] .. (path or "./.")
              end
            '';
      };

      extraPackages = with pkgs; [
        #     bash-language-server
        #     just-lsp
        #     lua-language-server
        #     marksman
        nixd
        nix-doc
        #     pyright
        #     ruff
        #     taplo
        #     typos-lsp
        #     vscode-json-languageserver
      ];
    };

    # ---- SEARCH SPEC ----
    specs.search = {
      after = [ "core" ];
      lazy = true;
      data = with pkgs.vimPlugins; [
        telescope-nvim
    #     telescope-fzf-native-nvim
    #     telescope-ui-select-nvim
    #     telescope-zoxide
    #     flash-nvim
    #     # ---- Additional from introdus ----
    #     # telescope-luasnip  # NOT in nixpkgs — needs plugins-telescope-luasnip flake input
      ];
      extraPackages = with pkgs; [
        zoxide
      ];
    };

    # ---- UI SPEC ----
    specs.ui = {
      after = [ "core" ];
      lazy = true;
      data = with pkgs.vimPlugins; [
        #     hardtime-nvim
        #     lualine-nvim
        #     neo-tree-nvim
        #     noice-nvim
        #     nvim-notify
        #     smart-splits-nvim
        #     tabby-nvim
        #     todo-comments-nvim
        #     trouble-nvim
        #     which-key-nvim
        #     # ---- Additional from introdus ----
        #     # snacks-nvim     # needs patching — see snacks override below
        #     # zen-mode       # NOT in nixpkgs — needs plugins-zen-mode flake input
        #     # confirm-quit   # NOT in nixpkgs — needs plugins-confirm-quit flake input
        #     # scope-nvim     # NOT in nixpkgs — from emergentmind-neovim
        mini-base16 # NOT in nixpkgs — from emergentmind-neovim
        #     # nvim-highlight-colors # NOT in nixpkgs — from emergentmind-neovim
        #     # vim-illuminate # NOT in nixpkgs — from emergentmind-neovim
        #     # nvim-numbertoggle # NOT in nixpkgs — from emergentmind-neovim
        #     # modes         # NOT in nixpkgs — needs plugins-modes flake input
        #     # screenkey     # NOT in nixpkgs — needs plugins-screenkey flake input
        #     # toggleterm-nvim # NOT in nixpkgs — from emergentmind-neovim
      ];
      #   extraPackages = with pkgs; [
      #     chafa
      #   ];
    };

    # ---- GIT SPEC ----
    # specs.git = {
    #   after = [ "core" ];
    #   lazy = true;
    #   enable = config.settings.devMode;
    #   data = with pkgs.vimPlugins; [
    #     gitsigns-nvim
    #     neogit
    #   ];
    # };

    # ---- MARKDOWN SPEC ----
    # specs.markdown = {
    #   after = [ "core" ];
    #   lazy = true;
    #   data = with pkgs.vimPlugins; [
    #     vim-markdown-toc
    #     markdown-preview-nvim
    #     render-markdown-nvim
    #     obsidian-nvim
    #   ];
    # };

    # ---- AI SPEC ----
    # specs.ai = {
    #   after = [ "ui" "completion" ];
    #   lazy = true;
    #   enable = config.settings.devMode;
    #   data = with pkgs.vimPlugins; [
    #     codecompanion-nvim
    #     # ---- Additional from emergentmind-neovim ----
    #     # avante-nvim    # NOT in nixpkgs — from emergentmind-neovim
    #     # blink-cmp-avante # NOT in nixpkgs — from emergentmind-neovim
    #   ];
    # };

    # ---- DEBUG SPEC ----
    # specs.debug = {
    #   after = [ "core" ];
    #   lazy = true;
    #   data = with pkgs.vimPlugins; [
    #     nvim-dap
    #     nvim-dap-ui
    #     nvim-dap-virtual-text
    #     nvim-dap-python
    #     nvim-dap-lldb
    #   ];
    # };

    # ---- KDL SPEC ----
    # specs.kdl = {
    #   after = [ "format" ];
    #   lazy = true;
    #   enable = config.settings.devMode;
    #   data = with pkgs.vimPlugins; [
    #     kdl-vim
    #   ];
    # };

    # ============================================================================
    # SPEC MODS — adds extraPackages + mainInfo fields to every spec
    # ============================================================================
    specMods = {
      options.extraPackages = lib.mkOption {
        type = lib.types.listOf wlib.types.stringable;
        default = [ ];
      };
      options.mainInfo = lib.mkOption {
        type = wlib.types.attrsRecursive;
        default = { };
      };
    };

    extraPackages = config.specCollect (acc: v: acc ++ (v.extraPackages or [ ])) [ ];

    info = lib.mkMerge (
      config.specCollect (acc: v: acc ++ lib.optional (v.mainInfo or { } != { }) v.mainInfo) [ ]
    );
  };
}
