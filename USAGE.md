# How to write documents with Markdown

* Organize articles in directories, each directory is a chapter.
* Order of chapters is hard-coded in file `convert.sh` (parameter
  `all_chapter_dirs`), so that we can avoid complex/unnecessary way to order them.
* Chapter title is defined in file `_title.md` under chapter folder.
* Chapter summary is defined in file `_summary.md` under chapter folder.
* Additional links stored in file `_links.md` will be appended to chapter.

```
|- <language>/
    |- _lang.md: Full name of the language. REQUIRED. e.g. `English` for `en_US`.
    |- chapter_name_1/
        |- _title.md: Chapter title. REQUIRED
        |- _links.md: Additional links, will be appended to chapter. OPTIONAL
        |- _summary.md: Summary text of this chapter, will be displayed under
                        chapter title. OPTIONAL
        |- what_is_iredmail.md
        |- why_choose_iredmail.md
    |- chapter_name_2/
        |- ...
    |- chapter_name_3/
        |- ...
    |- ...
- html/css/markdown.css
- html/images/
```

* Articles will be ordered automatically, if you want to specify the order,
  prepend a digit number and `-` in article files, script `convert.sh` will
  remove this prefix during converting Markdown source file to HTML file. e.g.

```
- chapter_name_x/
    |- _title.md
    |- 1-what_is_iredmail.md
    |- 2-why_choose_iredmail.md
    |- 3-price.md
    ...
    |- 0-hidden_article.md
```

* If you don't want to show an article in index page, prepend `0-` in its
  file name as shown above.

* Run script `convert.sh` to convert Markdown files to HTML static files.

    * It will generate index file `html/index.html` which includes all articles
      with relative links to HTML files.
    * it also generates README.md file used by bitbucket.org as index page.

```bash
$ bash convert.sh
```

To recompile all files, append flag `--all`:

```bash
$ bash convert.sh --all
```
