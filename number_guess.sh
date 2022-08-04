#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUM=$(($RANDOM % 1000 + 1))

echo -e 'Enter your username:'
read NAME

while [[ ${#NAME} -gt 22 ]]
do
  echo -e 'Name must have less than 22 characters'
  read NAME
done



#verify if name exists in db
NAME_DB_RESULT=$($PSQL "SELECT username FROM users WHERE username = '$NAME'")
if [[ -z $NAME_DB_RESULT ]]
then
  echo -e "Welcome, $NAME! It looks like this is your first time here."
  #insert name into db
  NAME_DB_INSERT=$($PSQL "INSERT INTO users(username) VALUES ('$NAME')")
else
  #echo in case name existis in db
  DETAILS=$($PSQL "SELECT username,guess,games FROM users WHERE username = '$NAME'")
  echo $DETAILS | while IFS="|" read USER GUESS GAMES
  do
    echo -e "Welcome back, $USER! You have played $GAMES games, and your best game took $GUESS guesses."
  done
fi

GUESS_NUM=0
echo -e 'Guess the secret number between 1 and 1000:'
read GUESS
let GUESS_NUM++


until [[ $GUESS -eq $NUM ]]
do
  while [[ ! $GUESS =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read GUESS

  done
  while [[ $GUESS -gt $NUM ]]
  do
    echo "It's lower than that, guess again:"
    read GUESS
    let GUESS_NUM++
  done
  while [[ $GUESS -lt $NUM ]]
  do
    echo "It's higher than that, guess again:"
    read GUESS
    let GUESS_NUM++
  done
done

echo -e "You guessed it in $GUESS_NUM tries. The secret number was $NUM. Nice job!"
GAMES=$($PSQL "SELECT games FROM users WHERE username = '$NAME'")
if [[ -z $GAMES ]]
then
  GAME_INSERT=$($PSQL "UPDATE users SET games = 1 WHERE username = '$NAME'")
else
  GAME_INSERT=$($PSQL "UPDATE users SET games = ($GAMES + 1) WHERE username = '$NAME'")
fi

GUESS=$($PSQL "SELECT games FROM users WHERE username = '$NAME'")
BEST_GUESS_UPDATE=$($PSQL "UPDATE users SET guess=$GUESS_NUM WHERE username='$NAME' AND (guess>$GUESS_NUM OR guess ISNULL)")