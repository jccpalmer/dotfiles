return {
	"jakobkhansen/journal.nvim",

	config = function()
        require("journal").setup({
			filetype = "md",
			root = "~/GitHub/neovim/journal",
			date_format = "%Y-%m-%d",
			autocomplete_date_modifier = "end",

			journal = {

				format = "%Y/%m/daily/%d-%a",
				template = "# %A, %d %B %Y\n",
				frequency = { day = 1 },
				entries = {
					day = {
						format = "%Y/%m/daily/%d-%a",
						template = "# %A, %d %B %Y\n",
						frequency = { day = 1 },
					},
					week = {
						format = "%Y/%m/weekly/week-%W",
						template = "# Week %W, %b %Y\n",
						frequency = { day = 7 },
					},
					month = {
						format = "%Y/%m",
						template = "# %B %Y\n",
						frequency = { month = 1 },
					},
					year = {
						format = "%Y",
						template = "# %Y\n",
						frequency = { year = 1 },
					},
				},
			},
		})
    	end,
}
