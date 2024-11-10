#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -c"

echo Enter your username:
read USERNAME

STORED_USER=$($PSQL "select username, games_played, best_game from game_user where username = '$USERNAME'")

if [[ -z $STORED_USER ]]
then
  A=$($PSQL "insert into game_user(username, games_played, best_game) values('$USERNAME', 0, 0)")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  USERNAME=$(echo "$STORED_USER" | awk '{print $1}')
  GAMES_PLAYED=$(echo "$STORED_USER" | awk '{print $3}')
  BEST_GAME=$(echo "$STORED_USER" | awk '{print $5}')

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

MY_RANDOM=$(( ( RANDOM % 1000 )  + 1 ))
echo $MY_RANDOM
echo "Guess the secret number between 1 and 1000:"
read INPUT

ATTEMPTS=1

while [[ $INPUT != $MY_RANDOM ]]
do
  if [[ ! $INPUT =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $INPUT -lt $MY_RANDOM ]]
    then
      echo "It's higher than that, guess again:"
    else
      echo "It's lower than that, guess again:"
    fi
  fi
  read INPUT
  ATTEMPTS=$((ATTEMPTS+1))
done

FINAL_USER=$($PSQL "select games_played, best_game from game_user where username = '$USERNAME'")

BEST_GAME=$(echo "$FINAL_USER" | awk '{print $3}')

if (( ATTEMPTS < BEST_GAME || BEST_GAME == 0 )) 
then
  B=$($PSQL "update game_user set best_game = '$ATTEMPTS' where username = '$USERNAME'")
fi

echo "You guessed it in $ATTEMPTS tries. The secret number was $INPUT. Nice job!"
C=$($PSQL "update game_user set games_played = games_played + 1 where username = '$USERNAME'")
