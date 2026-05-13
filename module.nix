inputs:
{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
{
  imports = [ wlib.wrapperModules.neovim ];

  options.settings.devMode = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enables additional development plugins.";
  };

  options.settings.terminalMode = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable features for using neovim as your terminal and terminal multiplexer.";
  };

  options.settings.neovide = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable a neovide wrapper around the the generated nvim binary.";
  };

  options.settings.guifont = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = "Font to set from external nix config";
  };

  config.hosts.neovide.nvim-host.enable = config.settings.neovide;
  config.settings.aliases = [ "vi" "vim" ];

  # ============================================================================
  # CORE SPEC (always enabled — minimal bootstrap for all other specs)
  # ============================================================================
  config.specs.core = {
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
  # config.specs.completion = {
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
  # config.specs.editing = {
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
  # config.specs.format = {
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
  # config.specs.lsp = {
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
  # config.specs.search = {
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
  # config.specs.ui = {
  #   after = [ "core" ];
  #   lazy = true;
  #   data = with pkgs.vimPlugins; [
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
  #     # mini-base16    # NOT in nixpkgs — from emergentmind-neovim
  #     # nvim-highlight-colors # NOT in nixpkgs — from emergentmind-neovim
  #     # vim-illuminate # NOT in nixpkgs — from emergentmind-neovim
  #     # nvim-numbertoggle # NOT in nixpkgs — from emergentmind-neovim
  #     # modes         # NOT in nixpkgs — needs plugins-modes flake input
  #     # screenkey     # NOT in nixpkgs — needs plugins-screenkey flake input
  #     # toggleterm-nvim # NOT in nixpkgs — from emergentmind-neovim
  #   ];
  #   extraPackages = with pkgs; [
  #     chafa
  #   ];
  # };

  # ---- GIT SPEC ----
  # config.specs.git = {
  #   after = [ "core" ];
  #   lazy = true;
  #   enable = config.settings.devMode;
  #   data = with pkgs.vimPlugins; [
  #     gitsigns-nvim
  #     neogit
  #   ];
  # };

  # ---- MARKDOWN SPEC ----
  # config.specs.markdown = {
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
  # config.specs.ai = {
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
  # config.specs.debug = {
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
  # config.specs.kdl = {
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
  config.specMods = {
    options.extraPackages = lib.mkOption {
      type = lib.types.listOf wlib.types.stringable;
      default = [ ];
    };
    options.mainInfo = lib.mkOption {
      type = wlib.types.attrsRecursive;
      default = { };
    };
  };

  config.extraPackages = config.specCollect (acc: v: acc ++ (v.extraPackages or [ ])) [ ];
}