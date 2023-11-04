#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
INPUT=$1



HAVE_INPUT(){
  if [[ $INPUT =~ ^[0-9]+$ ]] #Input is a number
    then
      DATA=$($PSQL "SELECT elements.atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius
      FROM elements
      FULL JOIN properties ON elements.atomic_number = properties.atomic_number
      WHERE elements.atomic_number = $INPUT")
  elif [[ $INPUT =~ ^[A-Za-z]{1,2}$ ]] #Input is a symbol
    then
      DATA=$($PSQL "SELECT elements.atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius
      FROM elements
      FULL JOIN properties ON elements.atomic_number = properties.atomic_number
      WHERE elements.symbol = '$INPUT'")
  elif [[ $INPUT =~ ^[A-Za-z]{3,}$ ]] #Input is a name 
    then
      DATA=$($PSQL "SELECT elements.atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius
      FROM elements
      FULL JOIN properties ON elements.atomic_number = properties.atomic_number
      WHERE elements.name = '$INPUT'")
  fi

  if [[ -n $DATA ]]
  then
    echo "$DATA" | while IFS='|' read ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  else
      echo "I could not find that element in the database." 
  fi
}

NOT_HAVE_INPUT(){
  echo "Please provide an element as an argument."
} 

if [[ -n $INPUT ]]
  then
    HAVE_INPUT
  else
    NOT_HAVE_INPUT
  fi
