#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  SERVICES=$($PSQL "select * from services")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

MAIN_MENU
echo "Select an option:"
read SERVICE_ID
if [[ ! $SERVICE_ID =~ ^[0-9]+$ ]]
then
  MAIN_MENU
fi

echo -e "\nEnter a customer phone:"
read CUSTOMER_PHONE

NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")
if [[ -z $NAME ]]
then
  echo -e "\nEnter a customer name:"
  read CUSTOMER_NAME
fi

echo -e "\nEnter a service time:"
read SERVICE_TIME

CUSTOMERS=$($PSQL "select * from customers where phone = '$CUSTOMER_PHONE'")
if [[ -z $CUSTOMERS ]]
then
  $($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  CUSTOMER_ID=$($PSQL "select customer_id from customers where name = '$CUSTOMER_NAME'")
  $($PSQL "insert into appointments(customer_id, service_id, time) values('$CUSTOMER_ID', '$SERVICE_ID', '$SERVICE_TIME')")
else
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
  $($PSQL "insert into appointments(customer_id, service_id, time) values('$CUSTOMER_ID', '$SERVICE_ID', '$SERVICE_TIME')")
fi

SERVICE_NAME=$($PSQL "select name from services where service_id = '$SERVICE_ID'")

if [[ -z $NAME ]]
then
  echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
else
  echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $NAME."
fi