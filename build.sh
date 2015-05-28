#!/bin/bash

### Define variables that we need for this script
### These are the chapters are are currently done. Add chapters here.
allDocuments=('blank' 'index' '1' '2' '3' '4' '5' '6' '7' '8' '9' '10' '11'
'12' '13' '14' 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I')
allChapters=('1' '2' '3' '4' '5' '6' '7' '8' '9' '10' '11'
'12' '13' '14' 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I')
misc=('blank' 'index')
chaptersWithFolders=('2' '3' '4' '5' '6' '7' '9' '12' '14' 'B' 'C' 'D' 'F' 'G' 'H')
chaptersWithOutFolders=('1' '8' '10' '11' '13' 'A' 'E' 'I')

foundDirs=()

### Turn on globbing (BASH 4 required)
shopt -s globstar

hello() {
  echo "Building the Cocos2d-x Programmers Guide..."
  echo ""
  echo "You can pass in --help for help on how to use this script."
  echo ""
}

help() {
  ## State what we need for this script to run
  echo "this script reqires: "
  echo ""
  echo "mkdocs: http://www.mkdocs.org/"
  echo "Pandoc: http://johnmacfarlane.net/pandoc/getting-started.html"
  echo "A LaTex Distribution: http://www.tug.org/mactex/downloading.html"
  echo "run: sudo /usr/local/texlive/2014basic/bin/universal-darwin/tlmgr update --self"
  echo "run: sudo /usr/local/texlive/2014basic/bin/universal-darwin/tlmgr install collection-fontsrecommended"
  echo "run: sudo /usr/local/texlive/2014basic/bin/universal-darwin/tlmgr install ec ecc"
  echo "export TEXROOT=/usr/local/texlive/2014basic/bin/universal-darwin/"
  echo "export PATH=$TEXROOT:$PATH"
  echo ""
  echo "To Do: Be able to insert a page break at the end of each chapter. right now it is continuous"
  echo ""
}

cleanUp() {
  echo "cleaning up cruft..."
  rm -rf print/
}

exitScript() {
  echo "exiting...."
  exit 0
}

deployToGitHub() {
  echo "deploying to GitHub Pages: ..."
  rsync -a site/ ../ChukongUSA.github.io/programmers-guide
  cd ../ChukongUSA.github.io/programmers-guide
  git add .
  git commit -m 'published automatically from script'
  git push
  cd ../../programmers-guide
}

buildHTML() {
  echo "building the html version with mkdocs..."
  echo "output is in site/..."
  echo "copying resources to respective directories..."
  rm -rf docs/
  mkdir -p docs
  mkdir -p print

  for i in ${chaptersWithFolders[@]}; do
    rsync -a chapters/${i}-web docs/
    rsync -a chapters/${i}-print print/
    mv docs/${i}-web docs/${i}-img
    mv print/${i}-print print/${i}-img
    cp chapters/${i}.md docs/${i}.md
    cp chapters/${i}.md print/${i}.md
  done

  for i in ${chaptersWithOutFolders[@]}; do
    cp chapters/${i}.md docs/${i}.md
    cp chapters/${i}.md print/${i}.md
  done

  for i in ${misc[@]}; do
    cp chapters/${i}.md docs/${i}.md
    cp chapters/${i}.md print/${i}.md
  done

  ## Now we can use MKDocs to build the static content
  echo "MKDocs Build..."
  rm -rf site/
  mkdocs build

  ## Now, lets copy the img folder to each chapter, we need to do this for theme
  ## path issues in the fact each directory is treated separately.
  ## We will get some errors here for chapters that dont yet exist
  for i in ${allChapters[@]}; do
    rsync -a theme/img site/${i}/
  done
}

buildPrint() {
  ## create HTML docs from the markdown files in the above array
  echo "building print version..."
  cp solarized-light.css main.css style.css _layout.html5 print/.

  for i in "${allDocuments[@]}"; do
    pandoc -s --template "_layout" --css "solarized-light.css" -f markdown -t html5 -o print/${i}.html print/${i}.md
  done

  ## create a PDF from the styled HTML
  echo "building ePub..."
  cd print/
  pandoc -S --epub-stylesheet="style.css" -o "ProgrammersGuide.epub" \
  index.html \
  blank.html \
  1.html \
  blank.html \
  2.html \
  blank.html \
  3.html \
  blank.html \
  4.html \
  blank.html \
  5.html \
  blank.html \
  6.html \
  blank.html \
  7.html \
  blank.html \
  8.html \
  blank.html \
  9.html \
  blank.html \
  10.html \
  blank.html \
  11.html \
  blank.html \
  12.html \
  blank.html \
  13.html \
  blank.html \
  14.html \
  blank.html \
  A.html \
  blank.html \
  B.html \
  blank.html \
  C.html \
  blank.html \
  D.html \
  blank.html \
  E.html \
  blank.html \
  F.html \
  blank.html \
  G.html \
  blank.html \
  H.html \
  blank.html \
  I.html \
  blank.html

  echo "building PDF..."
  pandoc -s ProgrammersGuide.epub --variable mainfont=Arial --variable monofont="Andale Mono" -o ProgrammersGuide.pdf --latex-engine=xelatex
  echo ""

  cd ..

  cp print/ProgrammersGuide.pdf print/ProgrammersGuide.epub site/.
}

main() {
  ## display opening message to user
  hello

  ## See what parameters the user has supplied.
  if (( $# == 1 )); then
    if [[ "--help" =~ $1 ]]; then ## user asked for help
      help
      exit 0
    fi
  fi

  ## we don't need parameters to run the script so build the documentation
  buildHTML
  buildPrint
  deployToGitHub
  cleanUp
  exitScript
}

## run our script.
main $1
