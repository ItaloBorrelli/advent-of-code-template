#!/bin/bash

eval "$(./resolve_date.sh "$@")"

echo "Year: $YEAR"
echo "Day: $DAY"

echo "This will initialize the folder and file structure for the given day."
echo "Are you satisfied with the above values?"

read -p "Note: Content in existing files will not be deleted. (y/n) " confirm
if [[ $confirm != [yY] ]]; then
    echo "Change the .env file to provide export the desired YEAR and DAY OR provide both/either value in the command line input."
    echo "Otherwise todays day and year will be used."
    exit 1
fi

INPUT_DIR="inputs/$YEAR/$DAY"

read -p "Create 'input.txt', 'test-answers.txt', and 'test-input.txt' files in '$INPUT_DIR'? (y/n) " confirm

if [[ $confirm == [yY] ]]; then
    mkdir -p $INPUT_DIR
    touch $INPUT_DIR/input.txt
    TEST_ANSWER_FILE="$INPUT_DIR/test-answers.txt"
    if [ ! -f $TEST_ANSWER_FILE ]; then
        touch $TEST_ANSWER_FILE
        echo "Couldn't run Part A!" >> $TEST_ANSWER_FILE
        echo "Couldn't run Part B!" >> $TEST_ANSWER_FILE
    fi
    touch $INPUT_DIR/test-input.txt
fi

SOLVE_DIR="src/AOC/Y$YEAR"
SOLVE_FILE_NAME="Day$DAY.hs"
SOLUTION_FILE="$SOLVE_DIR/$SOLVE_FILE_NAME"
if [ ! -f $SOLUTION_FILE ]; then
    read -p "Create '$SOLVE_FILE_NAME' file in '$SOLVE_DIR'? (y/n) " confirm

    if [[ $confirm == [yY] ]]; then
        mkdir -p $SOLVE_DIR
        cp ./Day.hs.template $SOLUTION_FILE
        sed -i "s/DayXX/Day$DAY/g" $SOLUTION_FILE
        echo "Created $SOLUTION_FILE"
    else
        echo "File already exists."
    fi
fi

MAIN_FILE="app/Main.hs"
IMPORT_STATEMENT="import qualified AOC.Y$YEAR.Day$DAY as Y${YEAR}Day${DAY}"
if ! grep -q "$IMPORT_STATEMENT" "$MAIN_FILE"; then
    sed -i "/--- Day imports/a $IMPORT_STATEMENT" "$MAIN_FILE"
    echo "Added import statement to $MAIN_FILE"
fi

echo $'\nIn app/Main.hs add:'
echo "import qualified AOC.Y$YEAR.Day$DAY as Y${YEAR}Day${DAY}"
echo $'\nIn the days function:'
echo "(${YEAR}${DAY}, (Y${YEAR}Day${DAY}.runDay, \"inputs/${YEAR}/${DAY}/input\"))"
echo $'\nIn test/Spec.hs add:'
echo "it \"${YEAR}${DAY}\" $ do runDay (\"${YEAR}\", \"${DAY}\")"
echo $'\nThen run stack build.'
