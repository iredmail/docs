#!/usr/bin/env bash

# Author: Zhang Huangbin <zhb _at_ iredmail.org>
# Purpose: Convert markdown articles to HTML files.

ROOTDIR="$(pwd)"

CONVERTER="${ROOTDIR}/tools/markdown2html.py"
CMD_CONVERT="python ${CONVERTER}"
#CMD_CONVERT=":"
CHANGED_FILES="$(hg st | grep '\.md$')"
TODAY="$(date +%Y-%m-%d)"

strip_name_prefix()
{
    name="${1}"
    name="$(echo ${name/#\.\//})"  # ./filename
    name="$(echo ${name/#[0-9][0-9][0-9]-/})"   # nnn-
    name="$(echo ${name/#[0-9][0-9]-/})"        # nn-
    name="$(echo ${name/#[0-9]-/})"             # n-
    echo "${name}"
}

# Available translations
all_languages='en_US zh_CN'

# Chapter directories in specified order
all_chapter_dirs="overview \
                  installation \
                  mua \
                  upgrade \
                  migrations \
                  howto \
                  integrations \
                  cluster \
                  troubleshooting \
                  faq"

# Additional directories which stores scripts or other non-Markdown files.
additional_dirs=""

# Compile all Markdown files.
if echo "$@" | grep -q -- '--all' &>/dev/null; then
    compile_all='YES'
fi

article_counter=0
echo -n "* Processing Markdown files: "

for lang in ${all_languages}; do
    src_dir="${ROOTDIR}/${lang}"
    if [ ! -d ${src_dir} ]; then
        echo "* [SKIP] No translation for ${lang} (${src_dir})."
        break
    fi

    cd ${src_dir}

    # Directory used to store converted html files.
    OUTPUT_DIR="${ROOTDIR}/html"
    CSS_FILE='./css/markdown.css'
    if [ X"${lang}" != X'en_US' ]; then
        OUTPUT_DIR="${ROOTDIR}/html/${lang}"
        CSS_FILE='../css/markdown.css'
    fi

    # Markdown file used to store index of chapters/articles.
    INDEX_MD="${OUTPUT_DIR}/index.md"

    [ -d ${OUTPUT_DIR} ] || mkdir -p ${OUTPUT_DIR}

    # Initial index file.
    if [ -f ${src_dir}/_title.md ]; then
        cat ${src_dir}/_title.md > ${INDEX_MD}
    else
        echo '' > ${INDEX_MD}
    fi

    # Used for prettier printing
    break_line='NO'

    # Get chapter info
    #   - chapter summary: _summary.md
    #   - article title: _title.md
    for chapter_dir in ${all_chapter_dirs}; do
        if [ ! -d ${chapter_dir} ]; then
            continue
        fi

        # Get articles
        all_chapter_articles="$(find ${chapter_dir} -depth 1 -type f -iname '[0-9a-z]*.md')"

        # Output directory.
        # Remove prefix '[number]-' in chapter directory name.
        #chapter_dir_in_article="$(strip_name_prefix ${chapter_dir})"
        #_output_chapter_dir="${OUTPUT_DIR}/${chapter_dir_in_article}"

        # Get chapter title.
        _title_md="${chapter_dir}/_title.md"
        _summary_md="${chapter_dir}/_summary.md"

        if [ -f ${_title_md} ]; then
            # generate index info of chapter
            _chapter_title="$(cat ${_title_md})"
            echo -e "### ${_chapter_title}" >> ${INDEX_MD}

            if [ -f ${_summary_md} ]; then
                echo '' >> ${INDEX_MD}
                cat ${_summary_md} >> ${INDEX_MD}

                # Insert an empty line to not mess up other formats like list.
                echo '' >> ${INDEX_MD}
            fi
        fi

        # Article info:
        #   - title: first line (without '#') of markdown file
        for article_file in ${all_chapter_articles}; do
            article_counter="$((article_counter+1))"
            article_file_basename="$(basename ${article_file})"
            article_html_file="$(strip_name_prefix ${article_file_basename})"
            # Replace '.md' suffix by '.html'
            article_html_file="$(echo ${article_html_file/%.md/.html})"

            hide_article_in_index='NO'
            if echo "${article_file_basename}" | grep '^0-' &>/dev/null; then
                hide_article_in_index='YES'
            fi

            # Get title in markdown file: '# title'
            _article_title="$(head -1 ${article_file} | awk -F'# ' '{print $2}')"

            #
            # Get title in markdown file: 'Title: title'
            #_article_title="$(grep '^Title: ' ${article_file} | head -1 | awk -F'Title: ' '{print $2}')"
            #
            # Get title in markdown file: '<h1>title</h1>'
            #_article_title="$(head -1 ${article_file} | awk -F'[<|>]' '{print $3}')"

            if [ X"${hide_article_in_index}" == X'NO' ]; then
                echo "* [${_article_title}](${article_html_file})" >> ${INDEX_MD}
            fi

            # Convert modified file
            echo ${CHANGED_FILES} | grep ${article_file} &> /dev/null
            compile_this_file="$?"

            if [ X"${compile_this_file}" == X'0' -o X"${compile_all}" == X'YES' ]; then
                if [ X"${break_line}" == X'YES' ]; then
                    echo -en "* Converting (#${article_counter}): ${lang}/${article_file}"
                else
                    echo -en "\n* Converting (#${article_counter}): ${lang}/${article_file}"
                fi

                # Convert
                ${CMD_CONVERT} ${article_file} \
                               ${OUTPUT_DIR} \
                               output_filename="${article_html_file}" \
                               title="${_article_title}" \
                               add_index_link='yes' \
                               css="${CSS_FILE}"

                if [ X"$?" == X'0' ]; then
                    echo -e ' [DONE]'
                else
                    echo -e ' <<< FAILED >>>'
                fi

                break_line='YES'
            else
                echo -n '.'
                break_line='NO'
            fi
        done

        # Append addition links at the chapter bottom on index page.
        _links_md="${chapter_dir}/_links.md"

        if [ -f ${_links_md} ]; then
            echo '' >> ${INDEX_MD}
            cat ${_links_md} >> ${INDEX_MD}
            echo '' >> ${INDEX_MD}
        fi
    done

    # Copy additional directories.
    for d in ${additional_dirs}; do
        cp -rf ${d} ${OUTPUT_DIR} &>/dev/null
    done

    echo ''
    echo "* ${article_counter} files total for ${lang}."

    echo "* Converting ${INDEX_MD} for index page."
    ${CMD_CONVERT} ${INDEX_MD} ${OUTPUT_DIR} title="iRedMail Documentations" css="${CSS_FILE}"

    # Cleanup and reset variables
    rm -f ${INDEX_MD}
    article_counter=0
done

# Sync newly generated HTML files to local diretories.
if echo "$@" | grep -q -- '--sync-local'; then
    # Copy to local hg repo of http://www.iredmail.org/docs/
    echo "* Syncing converted HTML files."
    rm -rf ../web/docs/*
    cp -rf ${ROOTDIR}/html/* ${ROOTDIR}/../web/docs/

    # Copy to iredmail.com/docs/
    rm -rf /Volumes/STORAGE/Dropbox/Backup/iredmail.com/docs/*
    cp -rf ${ROOTDIR}/html/* /Volumes/STORAGE/Dropbox/Backup/iredmail.com/docs/
fi

# Show changed files.
echo "* Changed files:"
echo "---------------"
hg st
echo "---------------"
