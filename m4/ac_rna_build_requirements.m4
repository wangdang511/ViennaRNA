AC_DEFUN([RNA_CHECK_BUILD_REQUIREMENTS], [

## Check for any tool required to build source files
##
## These tools should only be required for maintainer builds,
## since the generated files are usually distributed along
## with the distribution tar ball
RNA_CHECK_SRC_BUILDERS

## Check for presence of (or capability to generate) the
## Postscript templates we use for RNA secondary structure-
## and Dot plots.
RNA_CHECK_POSTSCRIPT_TEMPLATES

])


AC_DEFUN([RNA_CHECK_SRC_BUILDERS], [
    AC_ARG_VAR([XXD], [the 'xxd' program to convert text files into C include header files])
    AC_PATH_PROG([XXD], [xxd], [no])
    AC_SUBST([XXD])
    AM_CONDITIONAL(VRNA_AM_SWITCH_HAS_XXD, test "x$XXD" != "xno")

    AC_ARG_VAR([GENGETOPT], [the 'gengetopt' program to generate command line argument parsers for executable programs])
    AC_PATH_PROG([GENGETOPT], [gengetopt], [no])
    AC_SUBST([GENGETOPT])
    AM_CONDITIONAL(VRNA_AM_SWITCH_HAS_GENGETOPT, test "x$GENGETOPT" != "xno")

    AC_ARG_VAR([HELP2MAN], [the 'help2man' script to generate man pages from command line options of our executable programs])
    AC_PATH_PROG([HELP2MAN], [help2man], [no])
    AC_SUBST([HELP2MAN])
    AM_CONDITIONAL(VRNA_AM_SWITCH_HAS_HELP2MAN, test "x$HELP2MAN" != "xno")
])


AC_DEFUN([RNA_CHECK_POSTSCRIPT_TEMPLATES], [
    STATIC_FILE_DIR="${srcdir}/src/ViennaRNA/static"
    POSTSCRIPT_FILE_LIST="$STATIC_FILE_DIR/ps_templates.txt"

    ## load list of postscript template files and replace '\n' by ' '
    PS_TEMPLATE_FILES=`cat $POSTSCRIPT_FILE_LIST | tr '\012' ' '`
    ## create list of hex postscript template files
    PS_TEMPLATE_FILES_HEX=`AS_ECHO("$PS_TEMPLATE_FILES") | sed 's/.ps/.hex/g'`

    if test "x$XXD" = "xno"
    then
        for template in $PS_TEMPLATE_FILES_HEX
        do
            AC_RNA_TEST_FILE($STATIC_FILE_DIR/$template,[],[
                AC_MSG_ERROR([
=================================================
Can't find the postscript hex template

${template}

Make sure you've installed the 'xxd' tool to
generate it from source!
=================================================
])
            ])
        done
    fi

    # prepare substitution string for
    # templates_postscript.h file
    PS_TEMPLATE_CONST=""
    for template in $PS_TEMPLATE_FILES_HEX
    do
      # remove the 'postscript/' prefix
      template_name=`AS_ECHO("$template") | sed 's/postscript\///g'`
      # remove the trailing .hex
      template_name=`AS_ECHO("$template_name") | sed 's/.hex//g'`

      # create a C variable defintion for the template
      # note [[]] will turn into [] after M4 processed everythin
      PS_TEMPLATE_CONST="$PS_TEMPLATE_CONST
static const char PS_$template_name[[]] = {
#include \"$template\"
};
"
    done

    # Add templates_postscript.h to the files to be processed by
    # the configure script
    AC_CONFIG_FILES([src/ViennaRNA/static/templates_postscript.h])

    # substitute C variable definitions
    AC_SUBST(PS_TEMPLATE_CONST)
    # hack to avoid placing the multiline PS_TEMPLATE_CONST into any Makefile
    _AM_SUBST_NOTMAKE(PS_TEMPLATE_CONST)

    # substitute file list for static/Makefile.am
    AC_SUBST(PS_TEMPLATE_FILES)
    AC_SUBST(PS_TEMPLATE_FILES_HEX)
])

