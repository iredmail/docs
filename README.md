如何用 Markdown 来写作电子书。主要仿 gitbooks.io

o 使用目录来区分各个章节。示例：

	- 1-introduction/
		|- _title.md
		|- _description.md
		|- 1-what_is_iredmail.md
		|- 2-why_choose_iredmail.md
		|- 3-price.md
	- 2-faq/
	- 3-install/

o 章节的介绍用目录里的 README.md 提供章节标题及章节的介绍性内容。

o 使用脚本 convert.sh 自动生成电子书的 index.html 文件，将章节按照顺序排列，生成完整的索引，并列出章节内部的所有文章。
