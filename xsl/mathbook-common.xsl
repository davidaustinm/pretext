<?xml version='1.0'?> <!-- As XML file -->

<!--********************************************************************
Copyright 2013 Robert A. Beezer

This file is part of MathBook XML.

MathBook XML is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 or version 3 of the
License (at your option).

MathBook XML is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with MathBook XML.  If not, see <http://www.gnu.org/licenses/>.
*********************************************************************-->

<!-- Identify as a stylesheet -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:xml="http://www.w3.org/XML/1998/namespace" 
    xmlns:date="http://exslt.org/dates-and-times"
    extension-element-prefixes="date"
>


<xsl:import href="./languages/mathbook-language-en.xsl" />

<!-- MathBook XML common templates                        -->
<!-- Text creation/manipulation common to HTML, TeX, Sage -->

<!-- So output methods here are just text -->
<xsl:output method="text" />

<!-- Parameters to pass via xsltproc "stringparam" on command-line            -->
<!-- Or make a thin customization layer and use 'select' to provide overrides -->
<!-- These here are independent of the output format as well                  -->
<!-- -->
<!-- Hints and solutions for exercises is configurable        -->
<!-- For example, in a text versus a solution manual          -->
<!-- Default is to show them, global switch can turn them off -->
<xsl:param name="hints.included" select="'yes'" />
<xsl:param name="solutions.included" select="'yes'" />
<!-- Author tools are for drafts, mostly "todo" items                 -->
<!-- and "provisional" citations and cross-references                 -->
<!-- Default is to hide todo's, inline provisionals                   -->
<!-- Otherwise ('yes'), todo's in red paragraphs, provisionals in red -->
<xsl:param name="author-tools" select="'no'" />
<!-- How many levels to table of contents  -->
<!-- Not peculiar to HTML or LaTeX or etc. -->
<!-- Sentinel indicates no choice made     -->
<xsl:param name="toc.level" select="''" />
<!-- How many levels in numbering of theorems, etc     -->
<!-- Followed by a sequential number across that level -->
<!-- For example "2" implies Theorem 5.3.12 is         -->
<!-- 12-th theorem, lemma, etc in 5.2                  -->
<xsl:param name="numbering.theorems.level" select="''" />
<!-- How many levels in numbering of equations     -->
<!-- Analagous to numbering theorems, but distinct -->
<xsl:param name="numbering.equations.level" select="''" />
<!-- Level where footnote numbering resets                                -->
<!-- For example, "2" would be sections in books, subsections in articles -->
<xsl:param name="numbering.footnotes.level" select="''" />

<!-- Strip whitespace text nodes from container elements                    -->
<!-- Improve source readability with whitespace control in text output mode -->
<!-- Newlines with &#xa; : http://stackoverflow.com/questions/723226/producing-a-new-line-in-xslt -->
<!-- Removing whitespace: http://stackoverflow.com/questions/1468984/xslt-remove-whitespace-from-template -->
<xsl:strip-space elements="mathbook book article letter" />
<xsl:strip-space elements="frontmatter chapter appendix section subsection subsubsection exercises references introduction conclusion paragraph subparagraph" />
<xsl:strip-space elements="docinfo author abstract" />
<xsl:strip-space elements="titlepage preface acknowledgement authorbiography foreword dedication colophon" />
<xsl:strip-space elements="theorem corollary lemma proposition claim fact conjecture proof" />
<xsl:strip-space elements="definition axiom principle" />
<xsl:strip-space elements="statement" />
<xsl:strip-space elements="example remark exercise hint solution" />
<xsl:strip-space elements="exercisegroup" />
<xsl:strip-space elements="note" />  <!-- TODO: biblio, record, etc too -->
<xsl:strip-space elements="ul ol dl" />
<xsl:strip-space elements="md mdn" />
<xsl:strip-space elements="sage figure index" />
<xsl:strip-space elements="table tgroup thead tbody row" />

<!-- ######### -->
<!-- Variables -->
<!-- ######### -->

<xsl:variable name="toc-level">
    <xsl:choose>
        <xsl:when test="$toc.level != ''">
            <xsl:value-of select="$toc.level" />
        </xsl:when>
        <xsl:when test="/mathbook/book">2</xsl:when>
        <xsl:when test="/mathbook/article and /mathbook/article/section">1</xsl:when>
        <xsl:when test="/mathbook/article">0</xsl:when>
        <xsl:when test="/mathbook/letter">0</xsl:when>
        <xsl:when test="/mathbook/memo">0</xsl:when>
        <xsl:otherwise>
            <xsl:message>MBX:ERROR: Table of Contents level not determined</xsl:message>
        </xsl:otherwise>
    </xsl:choose>
</xsl:variable>

<!-- User-supplied Numbering for Theorems, etc    -->
<!-- Respect switch, or provide sensible defaults -->
<xsl:variable name="numbering-theorems">
    <xsl:choose>
        <xsl:when test="$numbering.theorems.level != ''">
            <xsl:value-of select="$numbering.theorems.level" />
        </xsl:when>
        <xsl:when test="/mathbook/book">2</xsl:when>
        <xsl:when test="/mathbook/article and /mathbook/article/section">1</xsl:when>
        <xsl:when test="/mathbook/article">0</xsl:when>
        <xsl:when test="/mathbook/letter">0</xsl:when>
        <xsl:when test="/mathbook/memo">0</xsl:when>
        <xsl:otherwise>
            <xsl:message>MBX:ERROR: Theorem numbering level not determined</xsl:message>
        </xsl:otherwise>
    </xsl:choose>
</xsl:variable>

<!-- User-supplied Numbering for Equations    -->
<!-- Respect switch, or provide sensible defaults -->
<xsl:variable name="numbering-equations">
    <xsl:choose>
        <xsl:when test="$numbering.equations.level != ''">
            <xsl:value-of select="$numbering.equations.level" />
        </xsl:when>
        <xsl:when test="/mathbook/book">2</xsl:when>
        <xsl:when test="/mathbook/article and /mathbook/article/section">1</xsl:when>
        <xsl:when test="/mathbook/article">0</xsl:when>
        <xsl:when test="/mathbook/letter">0</xsl:when>
        <xsl:when test="/mathbook/memo">0</xsl:when>
        <xsl:otherwise>
            <xsl:message>MBX:ERROR: Equation numbering level not determined</xsl:message>
        </xsl:otherwise>
    </xsl:choose>
</xsl:variable>

<!-- User-supplied Numbering for Footnotes        -->
<!-- Respect switch, or provide sensible defaults -->
<xsl:variable name="numbering-footnotes">
    <xsl:choose>
        <xsl:when test="$numbering.footnotes.level != ''">
            <xsl:value-of select="$numbering.footnotes.level" />
        </xsl:when>
        <xsl:when test="/mathbook/book">2</xsl:when>
        <xsl:when test="/mathbook/article and /mathbook/article/section">1</xsl:when>
        <xsl:when test="/mathbook/article">0</xsl:when>
        <xsl:when test="/mathbook/letter">0</xsl:when>
        <xsl:when test="/mathbook/memo">0</xsl:when>
        <xsl:otherwise>
            <xsl:message>MBX:ERROR: Footnote numbering level not determined</xsl:message>
        </xsl:otherwise>
    </xsl:choose>
</xsl:variable>

<!-- Directories -->
<!-- Relative to top-level XML source tree -->
<!-- AND top-level HTML source tree        -->
<!-- Include trailing  slash               -->

<!-- tikz graphics directory for manufacture and HTML use -->
<!-- TODO: customize with processing directives -->
<xsl:variable name="tikz-dir">tikz/</xsl:variable>


<!-- ############## -->
<!-- Entry template -->
<!-- ############## -->

<!-- docinfo is metadata, retrieve as needed              -->
<!-- Otherwise, processs book, article, letter, memo, etc -->
<xsl:template match="/mathbook">
    <xsl:apply-templates select="*[not(self::docinfo)]" />
</xsl:template>


<!-- Mathematics (LaTeX/MathJax)                                                 -->
<!-- Multi-line displayed equations container, globally unnumbered or numbered   -->
<!-- mrow logic controls numbering, based on variant here, and per-row overrides -->
<!-- align if there are ampersands, gather otherwise                             -->
<!-- Output follows source line breaks                                           -->
<!-- Individual mrows are handled differently for HTML versus MathJax            -->
<!-- The intertext element assumes an align environment for HTML output          -->
<xsl:template match="md|mdn">
    <xsl:choose>
        <xsl:when test="contains(., '&amp;')">
            <xsl:text>\begin{align}</xsl:text>
            <xsl:apply-templates select="mrow|intertext" />
            <xsl:text>\end{align}</xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:text>\begin{gather}</xsl:text>
            <xsl:apply-templates select="mrow" />
            <xsl:text>\end{gather}</xsl:text>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- Sanitize Sage code                 -->
<!-- No leading whitespace, no trailing -->
<!-- http://stackoverflow.com/questions/1134318/xslt-xslstrip-space-does-not-work -->
<xsl:variable name="whitespace"><xsl:text>&#x20;&#x9;&#xD;&#xA;</xsl:text></xsl:variable>

<!-- Trim all whitespace at end of code hunk -->
<!-- Append carriage return to mark last line, remove later -->
<xsl:template name="trim-end">
   <xsl:param name="text"/>
   <xsl:variable name="last-char" select="substring($text, string-length($text), 1)" />
   <xsl:choose>
        <xsl:when test="$last-char=''">
            <xsl:text>&#xA;</xsl:text>
        </xsl:when>
        <xsl:when test="contains($whitespace, $last-char)">
            <xsl:call-template name="trim-end">
                <xsl:with-param name="text" select="substring($text, 1, string-length($text) - 1)" />
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$text" />
            <xsl:text>&#xA;</xsl:text>
        </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<!-- Trim all totally whitespace lines from beginning of code hunk -->
<xsl:template name="trim-start-lines">
   <xsl:param name="text"/>
   <xsl:param name="pad" default="''"/>
   <xsl:variable name="first-char" select="substring($text, 1, 1)" />
   <xsl:choose>
        <!-- Possibly nothing, return just final carriage return -->
        <xsl:when test="$first-char=''">
            <xsl:text>&#xA;</xsl:text>
        </xsl:when>
        <xsl:when test="$first-char='&#xA;'">
            <xsl:call-template name="trim-start-lines">
                <xsl:with-param name="text" select="substring($text, 2)" />
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="contains($whitespace, $first-char)">
            <xsl:call-template name="trim-start-lines">
                <xsl:with-param name="text" select="substring($text, 2)" />
                <xsl:with-param name="pad"  select="concat($pad, $first-char)" />
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="concat($pad, $text)" />
        </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<!-- Compute length of indentation of first line                   -->
<!-- Assumes no leading blank lines                                -->
<!-- Assumes each line, including last, ends in a carriage return  -->
<xsl:template name="count-pad-length">
   <xsl:param name="text"/>
   <xsl:param name="pad" default=''/>
   <xsl:variable name="first-char" select="substring($text, 1, 1)" />
   <xsl:choose>
        <xsl:when test="$first-char='&#xA;'">
            <xsl:value-of select="string-length($pad)" />
        </xsl:when>
        <xsl:when test="contains($whitespace, $first-char)">
            <xsl:call-template name="count-pad-length">
                <xsl:with-param name="text" select="substring($text, 2)" />
                <xsl:with-param name="pad"  select="concat($pad, $first-char)" />
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="string-length($pad)" />
        </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<!-- An "out-dented" line is assumed to be intermediate blank line     -->
<!-- indent parameter is a number giving number of characters to strip -->
<xsl:template name="strip-indentation">
    <xsl:param name="text" />
    <xsl:param name="indent" />
    <xsl:if test="$text != ''">
        <xsl:variable name="first-line" select="substring-before($text, '&#xA;')" />
        <xsl:if test="string-length($first-line) > $indent" >
            <xsl:value-of select="substring($first-line, $indent + 1)" />
        </xsl:if>
        <xsl:text>&#xA;</xsl:text>
        <xsl:call-template name="strip-indentation">
            <xsl:with-param name="text" select="substring-after($text, '&#xA;')" />
            <xsl:with-param name="indent" select="$indent" />
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- Add a common string in front of every line of a block -->
<!-- Typically spaces to format output block for doctest   -->
<!-- indent parameter is a string                          -->
<!-- Assumes last character is xA                          -->
<!-- Result has trailing xA                                -->
<xsl:template name="add-indentation">
    <xsl:param name="text" />
    <xsl:param name="indent" />
    <xsl:if test="$text != ''">
        <xsl:value-of select="concat($indent,substring-before($text, '&#xA;'))" />
        <xsl:text>&#xA;</xsl:text>
        <xsl:call-template name="add-indentation">
            <xsl:with-param name="text" select="substring-after($text, '&#xA;')" />
            <xsl:with-param name="indent" select="$indent" />
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!--
1) Trim all trailing whitespace, add carriage return marker to last line
2) Strip all totally blank leading lines
3) Determine indentation of first line
4) Strip indentation from all lines
5) Allow intermediate blank lines
-->
<xsl:template name="sanitize-sage">
    <xsl:param name="raw-sage-code" />
    <xsl:variable name="trimmed-sage-code">
        <xsl:call-template name="trim-start-lines">
            <xsl:with-param name="text">
                <xsl:call-template name="trim-end">
                    <xsl:with-param name="text" select="$raw-sage-code" />
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="pad-length">
        <xsl:call-template name="count-pad-length">
            <xsl:with-param name="text" select="$trimmed-sage-code" />
        </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="strip-indentation" >
        <xsl:with-param name="text" select="$trimmed-sage-code" />
        <xsl:with-param name="indent" select="$pad-length" />
    </xsl:call-template>
</xsl:template>

<!-- Substrings at last markers               -->
<!-- XSLT Cookbook, 2nd Edition               -->
<!-- Recipe 2.4, nearly verbatim, reformatted -->
<xsl:template name="substring-before-last">
    <xsl:param name="input" />
    <xsl:param name="substr" />
    <xsl:if test="$substr and contains($input, $substr)">
        <xsl:variable name="temp" select="substring-after($input, $substr)" />
        <xsl:value-of select="substring-before($input, $substr)" />
        <xsl:if test="contains($temp, $substr)">
            <xsl:value-of select="$substr" />
            <xsl:call-template name="substring-before-last">
                <xsl:with-param name="input" select="$temp" />
                <xsl:with-param name="substr" select="$substr" />
            </xsl:call-template>
        </xsl:if>
    </xsl:if>
</xsl:template>

<xsl:template name="substring-after-last">
    <xsl:param name="input"/>
    <xsl:param name="substr"/>
    <!-- Extract the string which comes after the first occurrence -->
    <xsl:variable name="temp" select="substring-after($input,$substr)"/>
    <xsl:choose>
        <!-- If it still contains the search string then recursively process -->
        <xsl:when test="$substr and contains($temp,$substr)">
            <xsl:call-template name="substring-after-last">
                <xsl:with-param name="input" select="$temp"/>
                <xsl:with-param name="substr" select="$substr"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$temp"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Date and Time Functions -->
<!-- http://stackoverflow.com/questions/1437995/how-to-convert-2009-09-18-to-18th-sept-in-xslt -->
<!-- http://remysharp.com/2008/08/15/how-to-default-a-variable-in-xslt/ -->
<xsl:template match="today">
    <xsl:variable name="format">
        <xsl:choose>
            <xsl:when test="@format"><xsl:value-of select="@format" /></xsl:when>
            <xsl:otherwise>month-day-year</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="datetime" select="substring(date:date-time(),1,10)" />
    <xsl:choose>
        <xsl:when test="$format='month-day-year'">
            <xsl:value-of select="date:month-name($datetime)" />
            <xsl:text> </xsl:text>
            <xsl:value-of select="date:day-in-month($datetime)" />
            <xsl:text>, </xsl:text>
            <xsl:value-of select="date:year($datetime)" />
        </xsl:when>
        <xsl:when test="$format='yyyy/mm/dd'">
            <xsl:value-of select="substring($datetime, 1, 4)" />
            <xsl:text>/</xsl:text>
            <xsl:value-of select="substring($datetime, 6, 2)" />
            <xsl:text>/</xsl:text>
            <xsl:value-of select="substring($datetime, 9, 2)" />
        </xsl:when>
    </xsl:choose>
</xsl:template>

<!-- Could use a format to suppress/manipulate time zone -->
<xsl:template match="timeofday">
    <xsl:value-of select="substring(date:date-time(),12,8)" />
    <xsl:text> (</xsl:text>
    <xsl:value-of select="substring(date:date-time(),20)" />
    <xsl:text>)</xsl:text>
</xsl:template>

<!-- Levels -->
<!-- root is -2, mathbook is -1    -->
<!-- book, article, etc is 0       -->
<!-- sectioning works its way down -->
<!-- http://bytes.com/topic/net/answers/572365-how-compute-nodes-depth-xslt -->
<xsl:template match="*" mode="level">
    <xsl:value-of select="count(ancestor::node())-2" />
</xsl:template>

<!-- Structural Nodes -->
<!-- Some elements of the XML tree -->
<!-- are part of the document tree -->
<xsl:template match="*" mode="is-structural">
    <xsl:value-of select="self::book or self::article or self::frontmatter or self::chapter or self::appendix or self::preface or self::acknowledgement or self::authorbiography or self::foreword or self::dedication or self::colophon or self::section or self::subsection or self::subsubsection or self::exercises or self::references" />
</xsl:template>

<!-- Structural Leaves -->
<!-- Some elements of the document tree -->
<!-- are the leaves of that tree        -->
<xsl:template match="*" mode="is-leaf">
    <xsl:variable name="structural"><xsl:apply-templates select="." mode="is-structural" /></xsl:variable>
    <xsl:choose>
        <xsl:when test="$structural='true'">
            <xsl:value-of select="not(child::book or child::article or child::chapter or child::frontmatter or child::appendix or child::preface or child::acknowledgement or child::authorbiography or child::foreword or child::dedication or child::colophon or child::section or child::subsection or child::subsubsection or child::exercises or child::references)" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$structural" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- Names                                          -->
<!-- Relies on translations in language files       -->
<!-- which provides the named template, type-name   -->
<!-- This template allows a node to report its name -->
<xsl:template match="*" mode="type-name">
    <xsl:call-template name="type-name">
        <xsl:with-param name="generic" select="local-name(.)" />
    </xsl:call-template>
</xsl:template>

<!-- ################## -->
<!-- Identifiers        -->
<!-- ################## -->

<!-- Internal Identifier                                 -->
<!-- A unique text identifier for any element   -->
<!-- Uses:                                      -->
<!--   HTML: filenames (pages and knowls)       -->
<!--   HTML: anchors for references into pages  -->
<!--   LaTeX: labels, ie cross-references       -->
<!-- Format:                                            -->
<!--   the content (text) of an xml:id if provided      -->
<!--   otherwise, element_name-serial_number (doc-wide) -->
<!-- MathJax:                                                   -->
<!--   Can manufacture an HTML id= for equations, so            -->
<!--   we configure MathJax to use the TeX \label contents      -->
<!--   which we must be sure to provide via this routine here   -->
<!--   Then our URL/anchor scheme will point to the right place -->
<!--   So this is applied to men and (numbered) mrow elements    -->
<xsl:template match="*" mode="internal-id">
    <xsl:choose>
        <xsl:when test="@xml:id">
            <xsl:value-of select="@xml:id" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="local-name(.)" />
            <xsl:text>-</xsl:text>
            <xsl:number level="any" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Textual Representations of structural elements  -->
<!--   conveniences for annotating derivative products -->
<!--   such as Sage doc tests, LaTeX source            -->
<!--   Short names for filenames, ids                  -->
<!--   Long names (below) for content                  -->

<xsl:template match="chapter" mode="short-name">
    <xsl:text>chap-</xsl:text>
    <xsl:apply-templates select="." mode="number" />
</xsl:template>

<xsl:template match="section" mode="short-name">
    <xsl:text>sec-</xsl:text>
    <xsl:apply-templates select="." mode="number" />
</xsl:template>

<xsl:template match="subsection" mode="short-name">
    <xsl:text>subsec-</xsl:text>
    <xsl:apply-templates select="." mode="number" />
</xsl:template>

<xsl:template match="subsubsection" mode="short-name">
    <xsl:text>subsubsec-</xsl:text>
    <xsl:apply-templates select="." mode="number" />
</xsl:template>

<xsl:template match="paragraph" mode="short-name">
    <xsl:text>para-</xsl:text>
    <xsl:apply-templates select="." mode="number" />
</xsl:template>

<!-- Long Names -->
<!-- Simple text representations of structural elements        -->
<!-- Type, number, title typically                             -->
<!-- Ignore footnotes in these constructions                   -->
<!-- Used for author's report, LaTeX typeout during processing -->
<xsl:template match="*" mode="long-name">
    <xsl:apply-templates select="." mode="type-name" />
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="." mode="number" />
    <xsl:if test="title">
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="title/node()[not(self::fn)]"/>
    </xsl:if>
</xsl:template>

<!-- Some units don't have titles or numbers -->
<!-- TODO: bibliography, abstract(?), others -->
<xsl:template match="preface|acknowledgement|authorbiography|foreword|dedication|colophon" mode="long-name">
    <xsl:apply-templates select="." mode="type-name" />
    <xsl:text> </xsl:text>
</xsl:template>

<!-- Numbering  -->
<!-- Nodes "know" how to number themselves, -->
<!-- which is helpful in a variety of places -->
<!-- Default is LaTeX's numbering scheme -->

<!-- Any node is enclosed in some structural node,          -->
<!-- this utility template computes the hierarchical number -->
<!-- of the enclosing structural node.                      -->
<!-- Level 0 (book, article) is ignored                     -->
<!-- TODO: need filter, if, to handle appendices formatting with letters-->
<xsl:template match="*" mode="structural-number">
    <xsl:number level="multiple" count="chapter|appendix|section|subsection|subsubsection|references|exercises" />
</xsl:template>

<!-- We truncate a structural number to a               -->
<!-- specfified number of terms.                        -->
<!-- The string ends with a period, for                 -->
<!-- subsequent concatenation, unless no                -->
<!-- terms are requested and then the string is empty   -->
<!-- for use when numbering is sequential document-wide -->
<xsl:template name="level-number" >
    <xsl:param name="number" />
    <xsl:param name="level" />
    <xsl:choose>
        <xsl:when test="$level=0"></xsl:when>
        <xsl:otherwise>
            <xsl:choose>
                <xsl:when test="$number=''">
                    <xsl:text>0.</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="substring-before($number, '.')" />
                    <xsl:text>.</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="level-number">
                <xsl:with-param name="number">
                    <xsl:value-of select="substring-after($number, '.')" />
                </xsl:with-param>
                <xsl:with-param name="level">
                    <xsl:value-of select="$level - 1" />
                </xsl:with-param>
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Oops -->
<xsl:template match="*" mode="number">
    <xsl:text>[NUMBER]</xsl:text>
<!--
    <xsl:message terminate="no">
        <xsl:text>WARNING: trying to number a </xsl:text>
        <xsl:apply-templates select="." mode="type-name" />
        <xsl:text>, but this is not defined</xsl:text>
    </xsl:message>
-->
</xsl:template>

<!-- Numbering Structural Subdivisions -->
<!-- A structural node just gets its structural number,           -->
<!-- there is no truncation (can just not number at lower levels) -->
<xsl:template match="chapter|appendix|section|subsection|subsubsection|references|exercises" mode="number">
    <xsl:apply-templates select="." mode="structural-number" />
</xsl:template>

<!-- Numbering Subdivisions without Numbers -->
<!-- Only one, or not subdivisible, or ... -->
<!-- TODO: add more frontmatter, backmatter as it stabilizes -->
<xsl:template match="book|article|letter|memo|preface|frontmatter|introduction" mode="number"/>

<!-- Numbering Theorems, Definitions, Examples, Inline Exercises, Figures, etc.-->
<!-- Sructural to a configurable depth, then numbered across depth -->
<!-- We include figures and tables, which is different than LaTeX out-of-the-box behavior -->
<xsl:template match="theorem|corollary|lemma|proposition|claim|fact|definition|conjecture|axiom|principle|example|remark|exercise|figure|table" mode="number">
    <xsl:call-template name="level-number">
        <xsl:with-param name="number">
            <xsl:apply-templates select="." mode="structural-number" />
            <xsl:text>.</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="level">
            <xsl:value-of select="$numbering-theorems" />
        </xsl:with-param>
    </xsl:call-template>
    <!-- Books vs articles, translate level to from attribute node in sequential numbering -->
    <xsl:choose>
        <xsl:when test="/mathbook/book">
            <xsl:choose>
                <xsl:when test="$numbering-theorems=0"><xsl:number select="." from="book" level="any" count="theorem|corollary|lemma|proposition|claim|fact|definition|conjecture|axiom|principle|example|remark|exercise|figure|table"/></xsl:when>
                <xsl:when test="$numbering-theorems=1"><xsl:number select="." from="chapter" level="any" count="theorem|corollary|lemma|proposition|claim|fact|definition|conjecture|axiom|principle|example|remark|exercise|figure|table"/></xsl:when>
                <xsl:when test="$numbering-theorems=2"><xsl:number select="." from="section" level="any" count="theorem|corollary|lemma|proposition|claim|fact|definition|conjecture|axiom|principle|example|remark|exercise|figure|table"/></xsl:when>
                <xsl:when test="$numbering-theorems=3"><xsl:number select="." from="subsection" level="any" count="theorem|corollary|lemma|proposition|claim|fact|definition|conjecture|axiom|principle|example|remark|exercise|figure|table"/></xsl:when>
                <xsl:when test="$numbering-theorems=4"><xsl:number select="." from="subsubsection" level="any" count="theorem|corollary|lemma|proposition|claim|fact|definition|conjecture|axiom|principle|example|remark|exercise|figure|table"/></xsl:when>
                <xsl:otherwise>
                    <xsl:message>MBX:ERROR: Level for theorem number computation is out-of-bounds (<xsl:value-of select="$numbering-theorems" />)</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:when test="/mathbook/article">
            <xsl:choose>
                <xsl:when test="$numbering-theorems=0"><xsl:number select="." from="article" level="any" count="theorem|corollary|lemma|proposition|claim|fact|definition|conjecture|axiom|principle|example|remark|exercise|figure|table"/></xsl:when>
                <xsl:when test="$numbering-theorems=1"><xsl:number select="." from="section" level="any" count="theorem|corollary|lemma|proposition|claim|fact|definition|conjecture|axiom|principle|example|remark|exercise|figure|table"/></xsl:when>
                <xsl:when test="$numbering-theorems=2"><xsl:number select="." from="subsection" level="any" count="theorem|corollary|lemma|proposition|claim|fact|definition|conjecture|axiom|principle|example|remark|exercise|figure|table"/></xsl:when>
                <xsl:when test="$numbering-theorems=3"><xsl:number select="." from="subsubsection" level="any" count="theorem|corollary|lemma|proposition|claim|fact|definition|conjecture|axiom|principle|example|remark|exercise|figure|table"/></xsl:when>
                <xsl:otherwise>
                    <xsl:message>ERROR: Level for theorem number computation is out-of-bounds (<xsl:value-of select="$numbering-theorems" />)</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:message>ERROR: Level for theorem number computation implemented only for books, articles</xsl:message>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Numbering Equations -->
<xsl:template match="mrow|men" mode="number">
    <xsl:call-template name="level-number">
        <xsl:with-param name="number">
            <xsl:apply-templates select="." mode="structural-number" />
            <xsl:text>.</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="level">
            <xsl:value-of select="$numbering-equations" />
        </xsl:with-param>
    </xsl:call-template>

    <!-- Books vs articles, translate level to from attribute node in sequential numbering -->
    <xsl:choose>
        <xsl:when test="/mathbook/book">
            <xsl:choose>
                <xsl:when test="$numbering-equations=0"><xsl:number select="." from="book" level="any" count="men|md/mrow[@number = 'yes']|mdn/mrow[not(@number = 'no')]"/></xsl:when>
                <xsl:when test="$numbering-equations=1"><xsl:number select="." from="chapter" level="any" count="men|md/mrow[@number = 'yes']|mdn/mrow[not(@number = 'no')]"/></xsl:when>
                <xsl:when test="$numbering-equations=2"><xsl:number select="." from="section" level="any" count="men|md/mrow[@number = 'yes']|mdn/mrow[not(@number = 'no')]"/></xsl:when>
                <xsl:when test="$numbering-equations=3"><xsl:number select="." from="subsection" level="any" count="men|md/mrow[@number = 'yes']|mdn/mrow[not(@number = 'no')]"/></xsl:when>
                <xsl:when test="$numbering-equations=4"><xsl:number select="." from="subsubsection" level="any" count="men|md/mrow[@number = 'yes']|mdn/mrow[not(@number = 'no')]"/></xsl:when>
                <xsl:otherwise>
                    <xsl:message>MBX:ERROR: Level for theorem number computation is out-of-bounds (<xsl:value-of select="$numbering-equations" />)</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:when test="/mathbook/article">
            <xsl:choose>
                <xsl:when test="$numbering-equations=0"><xsl:number select="." from="article" level="any" count="men|md/mrow[@number = 'yes']|mdn/mrow[not(@number = 'no')]"/></xsl:when>
                <xsl:when test="$numbering-equations=1"><xsl:number select="." from="section" level="any" count="men|md/mrow[@number = 'yes']|mdn/mrow[not(@number = 'no')]"/></xsl:when>
                <xsl:when test="$numbering-equations=2"><xsl:number select="." from="subsection" level="any" count="men|md/mrow[@number = 'yes']|mdn/mrow[not(@number = 'no')]"/></xsl:when>
                <xsl:when test="$numbering-equations=3"><xsl:number select="." from="subsubsection" level="any" count="men|md/mrow[@number = 'yes']|mdn/mrow[not(@number = 'no')]"/></xsl:when>
                <xsl:otherwise>
                    <xsl:message>ERROR: Level for theorem number computation is out-of-bounds (<xsl:value-of select="$numbering-equations" />)</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:message>ERROR: Level for theorem number computation implemented only for books, articles</xsl:message>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- Equations:           -->
<!--   chapter.x in books -->
<!--   x in articles      -->
<!-- <xsl:template match="mrow|men" mode="number">
    <xsl:if test="ancestor::chapter">
        <xsl:apply-templates select="ancestor::chapter" mode="number" />
        <xsl:text>.</xsl:text>
    </xsl:if>
    <xsl:number from="chapter" level="any" count="men|md/mrow[@number = 'yes']|mdn/mrow[not(@number = 'no')]" />
</xsl:template>
 -->





<!-- Numbering Footnotes -->
<!-- At a configurable level                  -->
<!-- Sequential within subdivision,           -->
<!-- not unique across text unless level is 0 -->
<!-- TODO: consider endnotes possibly         -->
<xsl:template match="fn" mode="number">
    <xsl:choose>
        <xsl:when test="/mathbook/book">
            <xsl:choose>
                <xsl:when test="$numbering-footnotes=0"><xsl:number select="." from="book" level="any" count="fn" /></xsl:when>
                <xsl:when test="$numbering-footnotes=1"><xsl:number select="." from="chapter" level="any" count="fn" /></xsl:when>
                <xsl:when test="$numbering-footnotes=2"><xsl:number select="." from="section" level="any" count="fn" /></xsl:when>
                <xsl:when test="$numbering-footnotes=3"><xsl:number select="." from="subsection" level="any" count="fn" /></xsl:when>
                <xsl:when test="$numbering-footnotes=4"><xsl:number select="." from="subsubsection" level="any" count="fn" /></xsl:when>
                <xsl:otherwise>
                    <xsl:message>ERROR: Level for footnote number computation is out-of-bounds (<xsl:value-of select="$numbering-footnotes" />)</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:when test="/mathbook/article">
            <xsl:choose>
                <xsl:when test="$numbering-footnotes=0"><xsl:number select="." from="article" level="any" count="fn" /></xsl:when>
                <xsl:when test="$numbering-footnotes=1"><xsl:number select="." from="section" level="any" count="fn" /></xsl:when>
                <xsl:when test="$numbering-footnotes=2"><xsl:number select="." from="subsection" level="any" count="fn" /></xsl:when>
                <xsl:when test="$numbering-footnotes=3"><xsl:number select="." from="subsubsection" level="any" count="fn" /></xsl:when>
                <xsl:otherwise>
                    <xsl:message>ERROR: Level for footnote number computation is out-of-bounds (<xsl:value-of select="$numbering-footnotes" />)</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:message>ERROR: Level for footnote number computation implemented only for books, articles</xsl:message>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Numbering Exercises in Exercises Subdivision -->
<!-- Exercises sections can appear at any level, so we need         -->
<!-- the full structural number, then a sequential number           -->
<!-- Groupings of exercise might be intermediate, but do not hinder -->
<xsl:template match="exercises/exercise|exercises/exercisegroup/exercise" mode="number">
    <xsl:apply-templates select="." mode="structural-number" />
    <xsl:text>.</xsl:text>
    <xsl:number from="exercises" level="any" count="exercise" />
</xsl:template>

<!-- Numbering Bibliography Items in References -->
<!-- Structural number for References section, -->
<!-- plus sequential tacked on -->
<!-- A single number at book/article level -->
<xsl:template match="biblio" mode="number">
    <xsl:apply-templates select="." mode="structural-number" />
    <xsl:text>.</xsl:text>
    <xsl:number from="references" level="any" count="biblio" />
</xsl:template>

<!-- Warnings for high-frequency mistakes -->
<xsl:template match="cite">
    <xsl:message terminate="no">
    <xsl:text>WARNING: Citation (cite) with no ref or provisional attribute</xsl:text>
    </xsl:message>
</xsl:template>

<xsl:template match="xref">
    <xsl:message terminate="no">
    <xsl:text>WARNING: Cross-reference (xref) with no ref or provisional attribute</xsl:text>
    </xsl:message>
</xsl:template>

</xsl:stylesheet>