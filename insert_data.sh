#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# function: inserts team and returns team_id
insert_team() {
  # insert team
  RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$1')")
  # check result and print log
  if [[ $RESULT == 'INSERT 0 1' ]]
  then
    echo Team inserted: $1
  fi
  # return team id
  return $($PSQL "SELECT team_id FROM teams WHERE name='$1'")
}

# cleans tables
echo $($PSQL "TRUNCATE TABLE games,teams")

# insert data from games.csv
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # skip labels line
  if [[ $WINNER != 'winner' ]]
  then
    # search for winner team id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # if winner team not found
    if [[ -z $WINNER_ID ]]
    then
      # insert winner team
      insert_team "$WINNER"
      # store id 
      WINNER_ID=$?
    fi
    # search for opponent team id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # if opponent team not found
    if [[ -z $OPPONENT_ID ]]
    then
      # insert opponent team
      insert_team "$OPPONENT"
      # store id 
      OPPONENT_ID=$?
    fi
    # insert game
    RESULT=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND',$WINNER_ID,$OPPONENT_ID,$WINNER_GOALS,$OPPONENT_GOALS)")
    if [[ $RESULT == 'INSERT 0 1' ]]
    then
      echo Game inserted: $YEAR, $ROUND: $WINNER - $OPPONENT 
    fi
  fi
done

