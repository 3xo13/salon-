#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t -c "

SERVICES=$($PSQL "SELECT service_id,name FROM services") 




MAIN_MENU(){
  echo -e "\n~~~~~ MY SALON ~~~~~\n"

  echo -e "Welcome to My Salon, how can I help you?\n"

  if [[ $1 ]]
  then
    echo $1
  fi


  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do 
  echo "$SERVICE_ID) $SERVICE"
  done 

  read SERVICE_ID_SELECTED
}
MAIN_MENU

if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then
  MAIN_MENU 
  else
  # check service id
  SELECTED_SERVICE_RESULT=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED' ")
  echo $SELECTED_SERVICE_RESULT
  if [[ -z $SELECTED_SERVICE_RESULT ]]
  then 
    MAIN_MENU "I could not find that service. What would you like today?"
    else
      # get phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # if not alredy a customer get a name
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        # add customer
        ADD_CUSTOMER=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
      fi
      # get time
      echo -e "\nWhat time would you like your $SELECTED_SERVICE_RESULT, $CUSTOMER_NAME?"
      read SERVICE_TIME

      # get customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

      # add appointment
      ADD_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES('$CUSTOMER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME')")

      # success message
      echo -e "\nI have put you down for a $SELECTED_SERVICE_RESULT at $SERVICE_TIME, $CUSTOMER_NAME."

      
  fi

fi
