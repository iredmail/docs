如何用 Markdown 方便地整理和写作多章节文档。

* 使用目录来区分各个章节
* 章节的标题、介绍用目录里 _ 开头的文件来保存

```
- 1-introduction/
    |- _title.md
    |- _description.md
    |- 1-what_is_iredmail.md
    |- 2-why_choose_iredmail.md
    |- 3-price.md
- 2-faq/
- 3-install/
```

* 使用脚本 convert.sh 转换所有 Markdown 文件为 HTML 文件：

```bash
$ bash convert.sh
```

`convert.sh` 的作用是：

* 自动生成包含所有文档链接的总索引文件 `index.html`
* 将章节按照顺序排列
* 生成完整的索引，并列出章节目录内的所有文章
