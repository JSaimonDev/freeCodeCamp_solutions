#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

TRUNCATE_RESULT="$($PSQL "TRUNCATE games, teams RESTART IDENTITY CASCADE")"
if  [[ $TRUNCATE_RESULT == 'TRUNCATE TABLE' ]]
then
  echo -e "\n~~ Tables data reset ~~\n"
fi

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
if [[ $YEAR != "year" ]]
  then
  echo -e "\n* Match $WINNER vs $OPPONENT*\n  Result $WINNER_GOALS-$OPPONENT_GOALS"
  # Create winner team in the teams table if it doesnt exist
  WINNER_NAME="$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")"
  if [[ -z $WINNER_NAME ]]
  then
    INSERT_RESULT="$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")"
    echo -e "  $WINNER added to teams table"
  fi
  # Create opponent team in the teams table if it doesnt exist
  OPPONENT_NAME="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
  if [[ -z $OPPONENT_NAME ]]
  then
    INSERT_RESULT="$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")"
    echo -e "  $OPPONENT added to teams table"
  fi
  # Get winner and opponent id's
  WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
  OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
  # Insert data in games table 
  INSERT_RESULT="$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")"
  GAME_ID="$($PSQL "SELECT game_id FROM games WHERE year='$YEAR' AND round='$ROUND' AND winner_id='$WINNER_ID' AND opponent_id='$OPPONENT_ID'")"
  echo "  Game added to games table with ID = $GAME_ID"
fi
done