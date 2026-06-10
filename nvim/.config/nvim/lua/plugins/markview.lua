-- #rrggbb 두 색을 alpha 비율로 섞어 #rrggbb 반환 (헤딩 배경 바 틴트용)
local function blend(fg, bg, alpha)
	local function rgb(h)
		return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16)
	end
	local fr, fgr, fb = rgb(fg)
	local br, bgr, bb = rgb(bg)
	local function mix(a, b)
		return math.floor(a * alpha + b * (1 - alpha) + 0.5)
	end
	return string.format("#%02x%02x%02x", mix(fr, br), mix(fgr, bgr), mix(fb, bb))
end

-- kanagawa dragon 팔레트로 markview 헤딩에 레벨별 선명한 색을 입힘
local function set_markview_theme()
	local ok, kc = pcall(function()
		return require("kanagawa.colors").setup({ theme = "dragon" }).palette
	end)
	if not ok then
		return
	end
	local base = kc.dragonBlack3
	local levels = { kc.dragonRed, kc.dragonOrange, kc.dragonYellow, kc.dragonGreen, kc.dragonBlue, kc.dragonViolet }
	for i, fg in ipairs(levels) do
		vim.api.nvim_set_hl(0, "MarkviewHeading" .. i, { fg = fg, bg = blend(fg, base, 0.22), bold = true })
		vim.api.nvim_set_hl(0, "MarkviewHeading" .. i .. "Sign", { fg = fg, bg = "NONE" })
	end
end

return {
	-- markview와 render-markdown은 둘 다 in-buffer 렌더라 동시에 켜면 충돌한다.
	-- markview를 쓰는 동안 render-markdown은 끔. (되돌리려면 이 파일을 지우거나
	-- 아래 enabled=false를 지우면 render-markdown 설정이 다시 살아난다.)
	{ "MeanderingProgrammer/render-markdown.nvim", enabled = false },

	{
		"OXY2DEV/markview.nvim",
		ft = { "markdown", "codecompanion" },
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			preview = {
				icon_provider = "devicons",
				-- hybrid 모드: 커서가 있는 줄만 raw 마크업, 나머지는 전부 렌더
				hybrid_modes = { "n" },
			},
		},
		config = function(_, opts)
			require("markview").setup(opts)
			set_markview_theme()
			-- 컬러스킴 리로드 시 markview가 자체 색을 다시 깔므로, 그 뒤에 재적용
			vim.api.nvim_create_autocmd("ColorScheme", {
				callback = function()
					vim.schedule(set_markview_theme)
				end,
			})
		end,
	},
}
