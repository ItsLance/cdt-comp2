#!/bin/bash

# Set passwords for the users
warlock_password="Not@Warl0ck"
arowe_password="@Rrow0fChairs"

# Change passwords for both users
echo "Changing password for warlock..."
echo "warlock:$warlock_password" | sudo chpasswd

echo "Changing password for ARowe..."
echo "ARowe:$arowe_password" | sudo chpasswd

echo "Passwords have been successfully updated!"
