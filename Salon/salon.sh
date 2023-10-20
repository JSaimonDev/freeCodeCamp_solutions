#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t -c" 

echo -e "\n~~MY SALON~~"
echo -e "\nWelcome to my salon. How can I help you?\n"

SERVICE_MENU(){
  while true; do
    $PSQL "SELECT * FROM services;" | while IFS="|" read SERVICE_ID NAME
    do
      SERVICE_ID=$(echo $SERVICE_ID | xargs) # remove leading and trailing whitespace
      NAME=$(echo $NAME | xargs) # remove leading and trailing whitespace
      if [[ -n $SERVICE_ID ]]
      then
        echo "$SERVICE_ID) $NAME"
      fi
    done
    read SERVICE_ID_SELECTED
    HAVE_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_ID=$SERVICE_ID_SELECTED")
    if [[ -n $HAVE_SERVICE ]]
    then
      break
    else
      echo -e "\nI could not find that service. Please select a valid service."
    fi
  done
}

MAIN_MENU(){

SERVICE_MENU

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
HAVE_PHONE_NUMBER=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[ -z $HAVE_PHONE_NUMBER ]]
then
echo -e "\nWhat's your name?"
  read CUSTOMER_NAME
  $PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')"
fi

echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME"
read SERVICE_TIME

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU


