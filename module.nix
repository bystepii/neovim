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
        description = "Enables additional development plugins.";
      };

      terminalMode = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable features for using neovim as your terminal and terminal multiplexer.";
      };

      hotReload = lib.mkOption {
        type = lib.types.bool;
        default = config.settings.devMode;
        example = false;
        description = ''
          When enabled, neovim will use a mutable impure config path.
          This allows hot reloading of some settings. Defaults to the value of `devMode`.
          When disabled, an immutable pure config in the `/nix/store` will be used.
        '';
      };

      wrappedConfig = lib.mkOption {
        type = lib.types.either wlib.types.stringable lib.types.luaInline;
        default = "${configSource}";
        description = "Set of lua config files loaded into the /nix/store.";
      };

      unwrappedConfig = lib.mkOption {
        type = lib.types.nullOr (lib.types.either wlib.types.stringable lib.types.luaInline);
        default = null;
        example = lib.generators.mkLuaInline "vim.uv.os_homedir() .. '/dev/nix/neovim'";
        description = ''
          Set impure config path to load your config from.
          This value is used when hotReload is true.
        '';
      };

      baseConfig = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Base neovim config path for extending wrappers to reference.";
      };

      defaultCommand = lib.mkOption {
        type = lib.types.str;
        default = "luaeval('Snacks.dashboard()')";
        example = "execute('enew')";
        description = ''
          A default expression to be run when invoking bare nvim/vim/vi command
          while already nested inside a neovim terminal.
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

      cats = lib.mkOption {
        readOnly = true;
        type = lib.types.attrsOf lib.types.bool;
        default = lib.mapAttrs (_: v: v.enable) config.specs;
      };
    };

    nvim-lib = {
      pluginInputs = lib.mkOption {
        type = lib.types.listOf (lib.types.attrsOf wlib.types.stringable);
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
            (map (input:
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
    hosts.neovide.nvim-host.enable = config.settings.neovide;

    settings.config_directory =
      assert ((config.settings.hotReload == false) || (config.settings.unwrappedConfig != null));
      if config.settings.hotReload then
        config.settings.unwrappedConfig
      else
        config.settings.wrappedConfig;

    settings.aliases = [ "vi" "vim" ];

    # If run nested inside a neovim terminal, forward to parent via --remote
    runShell = [
      ''
        if ! ps -o ppid,comm -p $PPID | grep -q neovide && [[ $NVIM ]]; then
          if [ $# -eq 0 ]; then
            set -- --server $NVIM --remote-expr ${lib.escapeShellArg config.settings.defaultCommand}
          else
            set -- --server $NVIM --remote "$@"
          fi
        fi
        export TERM=xterm-256color
        ${if config.settings.baseConfig != null then
          ''export NVIM_BASE_CONFIG=${config.settings.baseConfig}''
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
    # specs.lsp = {
    #   after = [ "core" ];
    #   lazy = true;
    #   enable = config.settings.devMode;
    #   data = with pkgs.vimPlugins; [
    #     lazydev-nvim
    #     SchemaStore-nvim
    #     nvim-lspconfig
    #   ];
    #   extraPackages = with pkgs; [
    #     bash-language-server
    #     just-lsp
    #     lua-language-server
    #     marksman
    #     nixd
    #     nix-doc
    #     pyright
    #     ruff
    #     taplo
    #     typos-lsp
    #     vscode-json-languageserver
    #   ];
    # };

    # ---- SEARCH SPEC ----
    # specs.search = {
    #   after = [ "core" ];
    #   lazy = true;
    #   data = with pkgs.vimPlugins; [
    #     telescope-nvim
    #     telescope-fzf-native-nvim
    #     telescope-ui-select-nvim
    #     telescope-zoxide
    #     flash-nvim
    #     # ---- Additional from introdus ----
    #     # telescope-luasnip  # NOT in nixpkgs — needs plugins-telescope-luasnip flake input
    #   ];
    #   extraPackages = with pkgs; [
    #     zoxide
    #   ];
    # };

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
          mini-base16    # NOT in nixpkgs — from emergentmind-neovim
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
