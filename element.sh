#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table  --tuples-only -c"

if [[ -z $1 ]]
then
  echo Please provide an element as an argument.
else
  if [[ $1 =~ ^[+-]?[0-9]+$ ]] 
  then
    ELEMENT=$($PSQL "select * from elements where atomic_number = $1")
  else
    ELEMENT=$($PSQL "select * from elements where symbol = '$1' or name = '$1'")
  fi

  if [[ -z $ELEMENT ]]
  then
    echo I could not find that element in the database.
  fi
  
  echo "$ELEMENT" | while read ATOMIC_NUMBER BAR SYMBOL BAR NAME
  do
    if [[ $1 == $ATOMIC_NUMBER || $1 == $SYMBOL || $1 == $NAME ]]
    then
      printf "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). "

      PROPERTIES=$($PSQL "select atomic_number, type.type, atomic_mass, melting_point_celsius, boiling_point_celsius from properties inner join types type using(type_id) where atomic_number = $ATOMIC_NUMBER")
      echo "$PROPERTIES" | while read ATOMIC_NUMBER BAR TYPE BAR ATOMIC_MASS BAR MELTING_POINT_CELSIUS BAR BOILING_POINT_CELSIUS
      do
        printf "It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius.\n"
      done
    fi
  done
fi
