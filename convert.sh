#!/usr/bin/env bash

# Author: Zhang Huangbin <zhb _at_ iredmail.org>
# Purpose: Convert markdown articles to HTML files.

export ROOTDIR="$(pwd)"
export OUTPUT_DIR="${ROOTDIR}/html"

# A temporary directory used to copy and modify markdown files, will be removed
# after all files were converted.
export TMP_DIR="${OUTPUT_DIR}/tmp"

export CONVERTER="${ROOTDIR}/tools/markdown2html.py"
export CMD_CONVERT="python ${CONVERTER}"
export CHANGED_FILES="$(hg st | grep '\.md$')"
export TODAY="$(date +%Y-%m-%d)"

[ -d ${OUTPUT_DIR} ] || mkdir -p ${OUTPUT_DIR}
[ -d ${TMP_DIR} ] || mkdir -p ${TMP_DIR}

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
export all_languages='en_US it_IT lv_LV zh_CN'

# Chapter directories in specified order
export all_chapter_dirs="overview \
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

    # Markdown file used to store index of chapters/articles.
    INDEX_MD="${OUTPUT_DIR}/index.md"

    # Generate a index file.
    has_index='NO'
    if [ X"${lang}" == X'en_US' ]; then
        has_index='YES'
    fi

    cd ${src_dir}

    # Initial index file.
    if [ X"${has_index}" == X'YES' ]; then
        if [ -f ${src_dir}/_title.md ]; then
            cat ${src_dir}/_title.md > ${INDEX_MD}
        else
            echo '' > ${INDEX_MD}
        fi
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

        if [ X"${has_index}" == X'YES' ]; then
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
        fi

        # Article info:
        #   - title: first line (without '#') of markdown file
        for article_file in ${all_chapter_articles}; do
            article_counter="$((article_counter+1))"
            article_file_basename="$(basename ${article_file})"
            article_html_file_orig="$(strip_name_prefix ${article_file_basename})"
            # Replace '.md' suffix by '.html', and append lang code
            if [ X"${lang}" == X'en_US' ]; then
                article_html_file="$(echo ${article_html_file_orig/%.md/.html})"
            else
                article_html_file="$(echo ${article_html_file_orig/%.md/-${lang}.html})"
            fi

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

            if [ X"${hide_article_in_index}" == X'NO' -a X"${has_index}" == X'YES' ]; then
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

                # * Detect same file in different languages
                # * Modify markdown file to append a note paragraph to remind
                #   reader that current document has different language version.
                translations=''
                for tlang in ${all_languages}; do
                    if [ X"${tlang}" != X"${lang}" ]; then
                        if [ -f ${ROOTDIR}/${tlang}/${chapter_dir}/${article_file_basename} ]; then
                            translations="${translations} ${tlang}"
                        fi
                    fi
                done

                # Has translation(s).
                md_src="${article_file}"
                if echo ${translations} | grep '_' &>/dev/null; then
                    tmp_md_orig="${TMP_DIR}/${article_file_basename}-${lang}"
                    tmp_md="${TMP_DIR}/${article_file_basename}"

                    cp -f ${article_file} ${tmp_md_orig}

                    # Generate new markdown file
                    # Get title line
                    _title_line="$(head -1 ${tmp_md_orig})"
                    # Remove title line
                    perl -pi -e 's#${_title_line}##' ${tmp_md_orig}

                    echo -e "${title_line}\n\n" > ${tmp_md}
                    echo -e '!!! note "This tutorial is available in other languages"\n\n' >> ${tmp_md}

                    _md_l='\t'
                    for l in ${translations}; do
                        if [ X"${l}" == X'en_US' ]; then
                            tmp_article_html_file="$(echo ${article_html_file_orig/%.md/.html})"
                        else
                            tmp_article_html_file="$(echo ${article_html_file_orig/%.md/-${l}.html})"
                        fi
                        _md_l="${_md_l} [$(cat ${ROOTDIR}/${l}/_lang.md)](./${tmp_article_html_file}) /"
                    done
                    echo -e "${_md_l}\n" >> ${tmp_md}

                    cat ${tmp_md_orig} >> ${tmp_md}

                    md_src="${tmp_md}"
                    rm -f ${tmp_md_orig}
                fi

                # Convert
                ${CMD_CONVERT} ${md_src} \
                               ${OUTPUT_DIR} \
                               output_filename="${article_html_file}" \
                               title="${_article_title}" \
                               add_index_link='yes'

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
        if [ X"${has_index}" == X'YES' ]; then
            _links_md="${chapter_dir}/_links.md"
            if [ -f ${_links_md} ]; then
                echo '' >> ${INDEX_MD}
                cat ${_links_md} >> ${INDEX_MD}
                echo '' >> ${INDEX_MD}
            fi
        fi
    done

    # Copy additional directories.
    for d in ${additional_dirs}; do
        cp -rf ${d} ${OUTPUT_DIR} &>/dev/null
    done

    echo ''
    echo "* ${article_counter} files total for ${lang}."

    if [ X"${has_index}" == X'YES' ]; then
        echo "* Converting ${INDEX_MD} for index page."
        ${CMD_CONVERT} ${INDEX_MD} ${OUTPUT_DIR} title="iRedMail Documentations"

        # Cleanup and reset variables
        rm -f ${INDEX_MD}
    fi

    article_counter=0
done

rm -rf ${TMP_DIR} &>/dev/null

# Sync newly generated HTML files to local diretories.
if echo "$@" | grep -q -- '--sync-local'; then
    # Copy to local hg repo of http://www.iredmail.org/docs/
    echo "* Syncing converted HTML files."
    rm -rf ../web/docs/*
    cp -rf ${ROOTDIR}/html/* ${ROOTDIR}/../web/docs/
    cp -rf ${ROOTDIR}/html/images/* ${ROOTDIR}/../web/docs/images/
fi

# Show changed files.
echo "* Changed files:"
echo "---------------"
hg st
echo "---------------"
