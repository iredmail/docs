# How to write documents with Markdown

## Required Python modules

* markdown
* markdown_checklist

## Usage

* Organize articles in directories, each directory is a chapter.
* Order of chapters is hard-coded in file `convert.sh` (parameter
  `all_chapter_dirs`), so that we can avoid complex/unnecessary way to order them.
* Chapter title is defined in file `_title.md` under chapter folder.
* Chapter summary is defined in file `_summary.md` under chapter folder.
* Additional links stored in file `_links.md` will be appended to chapter.

```
|- <language>/              # Short language code. e.g. `en_US`. Required.
    |- _lang.md             # Full name of the language. REQUIRED. e.g. `English` for `en_US`.
    |- chapter_name_1/
        |- _title.md        # Chapter title. REQUIRED
        |- _links.md        # Additional links, will be appended to chapter. OPTIONAL
        |- _summary.md      # Summary text of this chapter, will be displayed
                            # under chapter title. OPTIONAL
        |- article-1.md
        |- article-2.md
        |- article-3.md
    |- chapter_name_2/
        |- ...
    |- chapter_name_3/
        |- ...
    |- ...

- html/css/markdown.css     # CSS file
- html/images/              # Place images you need to display in HTML files here
```

* Articles will be ordered automatically, if you want to specify the order,
  prepend a digit number and `-` in article files, script `convert.sh` will
  remove this prefix during converting Markdown source file to HTML file. e.g.
  `1-file1.md`, `2-file2.md`.
* If you don't want to show an article in index page, prepend `0-` in its
  file name as shown above.

```
- chapter_name_x/
    |- _title.md
    |- 1-article-a.md       # This article will be displayed as first one on index page
    |- 2-article-b.md       # 2nd article on index page
    |- 3-article-c.md       # 3rd article on index page
    ...
    |- 0-hidden_article.md  # This article will not be displayed on index page
```

* The first line in article file will be used as article title (string `# `
  at beginning of line will be removed). Note: it must be the first line in
  file, not the first non-empty line. For example:

```
# This is article title.
```

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
