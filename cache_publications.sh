# #!/usr/bin/env bash

# Break build on error, prevents websites going offline in case of pelican errors
set -e

EXCLUDES=(website-ai-for-health website-base)
gitdiff='git diff --quiet HEAD^ ./content/diag.bib'

for WEBSITE in website-*
do
    GENERATE_PUB=1
    for EXCLUDE in ${EXCLUDES[*]}
    do
        if [ $WEBSITE == $EXCLUDE ]; then
            GENERATE_PUB=0
        fi
    done

    echo $WEBSITE $GENERATE_PUB
    if [[ $GENERATE_PUB != '1' ]]; then
      echo "Skipping generation of publication pages for $WEBSITE."
    else

      # Check if diag bib changed 
      if ! $gitdiff; then

        echo "Generating publications for $WEBSITE"

        # Copy bib generator script
        cp -r plugins/bibtex $WEBSITE/plugins
        cp plugins/bib_writer.py $WEBSITE/plugins/bib_writer.py

        # Copy literature
        cp content/diag.bib $WEBSITE/content/diag.bib

        # Run the bib plugin
        cd $WEBSITE
        python plugins/bib_writer.py
        cd ..

      else
        echo "Diag bib not changed. Skipping generation of publiction (using current publications files)"
      fi
    fi
done

# Check if diag bib changed 
if ! $gitdiff; then
  # push publications
  ./push.sh
fi
