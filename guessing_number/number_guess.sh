#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=guessing_game -t --no-align -c"

RANDOM_NUMBER=$((RANDOM % 1000 + 1))
GUESS_COUNT=0
GAMES_PLAYED=0
BEST_GAME=0

echo Enter your username:
read USERNAME

FOUND_USER=$($PSQL "SELECT usr, games_played, best_game FROM guessing_game WHERE usr='$USERNAME'")

IFS=$'|' read -r USERNAME_DB GAMES_PLAYED_DB BEST_GAME_DB <<< $FOUND_USER

if [[ -n "$USERNAME_DB" ]] 
    then
      GAMES_PLAYED=$GAMES_PLAYED_DB
      BEST_GAME=$BEST_GAME_DB
        echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    else
        $PSQL "INSERT INTO guessing_game(usr, games_played, best_game) VALUES('$USERNAME', $GAMES_PLAYED, $BEST_GAME);"
        echo "Welcome, $USERNAME! It looks like this is your first time here."
    fi

GUESS_MENU(){
echo "Guess the secret number between 1 and 1000:"
read GUESSED_NUMBER

if [[ -n ${GUESSED_NUMBER//[0-9]/} ]]
then
  echo "That is not an integer, guess again:"
  GUESS_MENU
else
  if [[ $GUESSED_NUMBER -eq $RANDOM_NUMBER ]]
  then
    if [[ $GUESS_COUNT -lt $BEST_GAME || $BEST_GAME -eq 0 ]]
    then
      $PSQL "UPDATE guessing_game SET best_game=$GUESS_COUNT WHERE usr='$USERNAME'"
    fi
    GAMES_PLAYED=$((GAMES_PLAYED + 1))
    $PSQL "UPDATE guessing_game SET games_played=$GAMES_PLAYED WHERE usr='$USERNAME'"
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"

  else

    if [[ $GUESSED_NUMBER -lt $RANDOM_NUMBER ]]
    then 
      echo "It's higher than that, guess again:"
      GUESS_COUNT=$((GUESS_COUNT + 1))
    elif [[ $GUESSED_NUMBER -gt $RANDOM_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      GUESS_COUNT=$((GUESS_COUNT + 1))
    fi

    GUESS_MENU

  fi
fi  
}

GUESS_MENU
