-- ========================
-- 基础设置
-- ========================
vim.opt.number = true
vim.opt.relativenumber = true

-- ========================
-- 安装 lazy.nvim（bootstrap）
-- ========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        lazypath
    })
end

vim.opt.rtp:prepend(lazypath)

-- ========================
-- 按键映射
-- ========================
vim.keymap.set("i", "jk", "<Esc>")
vim.g.mapleader = " "

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

-- 使用空格键 + h 来手动清除
vim.keymap.set('n', '<leader>oh', '<cmd>nohlsearch<CR>')

--剪贴板共享
vim.opt.clipboard = "unnamedplus"

-- 让 * 键不再自动跳到下一个匹配项
vim.keymap.set('n', '*', '*N')

-- 普通模式下移动行
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { desc = 'Move line down' })
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { desc = 'Move line up' })

-- 可视模式下移动选中块
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })
--分屏
-- 增强窗口大小调整
vim.keymap.set("n", "<C-Left>",  ":vertical resize -5<CR>", {silent=true})
vim.keymap.set("n", "<C-Right>", ":vertical resize +5<CR>", {silent=true})
vim.keymap.set("n", "<C-Up>",    ":resize +2<CR>", {silent=true})
vim.keymap.set("n", "<C-Down>",  ":resize -2<CR>", {silent=true})

--插件映射
--telescope
vim.keymap.set("n", "<leader>ff", function()
    require("telescope.builtin").find_files()
end)

vim.keymap.set("n", "<leader>fg", function()
    require("telescope.builtin").live_grep()
end)

vim.keymap.set("n", "<leader>fG", function()
    require("telescope.builtin").live_grep({
        additional_args = function()
            return {"-F"}  -- 固定字符串搜索
        end
    })
end)

vim.keymap.set("n", "<leader>fb", function()
    require("telescope.builtin").buffers()
end)
-- nvim-tree 切换开关
vim.keymap.set('n', '<C-b>', ':NvimTreeToggle<CR>', { silent = true, noremap = true })

-- ========================
-- 插件列表
-- ========================
require("lazy").setup({
    --telescope
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
    },
    --LSPconfig
    {
        "neovim/nvim-lspconfig",
        --python
        config=function()
            vim.lsp.config('ty',{
                filetypes = { 'python' },
                setting={
                    ty={}
                }
            })

            vim.lsp.enable('ty')
            --cpp
            vim.lsp.config('clangd', {
            cmd = {
                "clangd",
                "--background-index",      -- 后台索引，跳转飞快
                "--clang-tidy",            -- 静态检查，帮你找逻辑漏洞
                "--header-insertion=iwyu", -- 自动插入缺少的 #include
                "--completion-style=detailed",
            },
            filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
            -- 确保开启语义标记支持，这是“ty 级别染色”的关键
            capabilities = {
                textDocument = {
                    semanticTokens = { dynamicRegistration = true }
                    }
                }
            })
            vim.lsp.enable('clangd')

        end
    },

    --blink.cmp
    {
        'saghen/blink.cmp',
        version = '*',
        opts = {
            keymap = {
                preset = 'default',
                ['<Tab>'] = { 'select_and_accept', 'snippet_forward', 'fallback' },
            },
            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },
            },
        },
    },
    --ColorTheme
    {   
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000, -- 确保它在其他插件之前加载
        config = function()
            -- 在这里设置你喜欢的口味：latte, frappe, macchiato, mocha
            require("catppuccin").setup({
                flavour = "mocha", -- 推荐 mocha，深色效果最好
                transparent_background = false,
                term_colors = true,
                integrations = {
                    cmp = true,      -- 配合补全插件
                    treesitter = true, -- 配合 Treesitter
                    native_lsp = {
                        enabled = true,
                        virtual_text = {
                            errors = { "italic" },
                            hints = { "italic" },
                            warnings = { "italic" },
                            information = { "italic" },
                        },
                        underlines = {
                            errors = { "undercurl" },
                            hints = { "undercurl" },
                            warnings = { "undercurl" },
                            information = { "undercurl" },
                        },
                        semantic_tokens = true, -- 【关键】必须设为 true 以支持 ty 的染色
                    },
                },
            })
            -- 这一行才是真正把墙刷成 Catppuccin 颜色的命令
            vim.cmd.colorscheme "catppuccin"
        end
    },
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        config = function()
            require("toggleterm").setup({
                -- 打开的快捷键 (这里设为 Ctrl + j)
                open_mapping = [[<c-j>]],
                direction = 'horizontal', -- 像 VS Code 一样在下方水平打开
                size = 15,                -- 终端高度
            })
        end
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter", -- 仅在进入插入模式时加载，节省启动时间
        config = true,         -- 相当于 require("nvim-autopairs").setup({})
    },
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
        build = ':TSUpdate',
        config = function()
            local ts = require('nvim-treesitter')

            -- 1. 基础设置
            ts.setup({
                install_dir = vim.fn.stdpath('data') .. '/site'
            })

            -- 2. 安装解析器
            ts.install({ 'lua', 'cpp', 'c', 'python' })

            -- 3. 【核心修改】启用功能
            -- 建议直接放在这里，每次进入对应文件类型时会自动触发
            vim.api.nvim_create_autocmd('FileType', {
                -- pattern 可以是你安装的语言，也可以用 '*' 代表所有语言
                pattern = { 'lua', 'cpp', 'c', 'python' }, 
                callback = function()
                    -- 开启语法高亮 (Treesitter 驱动)
                    -- 对应文档：:h treesitter-highlight
                    local ok, _ = pcall(vim.treesitter.start)
                    if not ok then return end

                    -- 开启基于 Treesitter 的代码折叠
                    vim.wo.foldmethod = 'expr'
                    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                    -- 默认不折叠（可选设置）
                    vim.wo.foldlevel = 99

                    -- 开启基于 Treesitter 的自动缩进（目前仍为实验性）
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end
    },
    {
      "nvim-tree/nvim-tree.lua",
      version = "*",
      lazy = false,
      dependencies = {
        "nvim-tree/nvim-web-devicons", -- 用于显示文件图标
      },
      config = function()
        require("nvim-tree").setup({
          sort_by = "case_sensitive",
          view = {
            width = 30, -- 侧边栏宽度
          },
          renderer = {
            group_empty = true,
          },
          filters = {
            dotfiles = false,
          },
        })
      end,
    },
    {	
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
	    require("lualine").setup({
	        options = {
		    theme = 'auto', -- 自动根据你的配色方案调整
		    component_separators = { left = '', right = ''},
		    section_separators = { left = '', right = ''},
	        }
	    })
        end
    },
})
