#!/bin/bash

# ANSI color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo -e "${RED}Usage: $0 <email> [<new_password>] [--phone <new_phone_number>]${NC}"
    exit 1
}

# Check if at least email is provided
if [ $# -lt 1 ]; then
    usage
fi

EMAIL=$1
shift

NEW_PASSWORD=""
NEW_PHONE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --phone)
            NEW_PHONE="$2"
            shift 2
            ;;
        *)
            NEW_PASSWORD="$1"
            shift
            ;;
    esac
done

# MongoDB connection string (modify as needed)
MONGO_URI="mongodb://localhost:27017/serverdash"

# Prepare update object
UPDATE_OBJ="{}"

if [ ! -z "$NEW_PASSWORD" ]; then
    # Hash the new password (using Node.js for consistency with your app)
    HASHED_PASSWORD=$(node -e "
    const crypto = require('crypto');
    const salt = crypto.randomBytes(16).toString('hex');
    const hashedPassword = crypto.pbkdf2Sync('$NEW_PASSWORD', salt, 1000, 64, 'sha512').toString('hex');
    console.log(JSON.stringify({salt: salt, hashedPassword: hashedPassword}));
    ")
    # Extract salt and hashedPassword
    SALT=$(echo $HASHED_PASSWORD | jq -r '.salt')
    HASHED_PW=$(echo $HASHED_PASSWORD | jq -r '.hashedPassword')
    UPDATE_OBJ=$(echo $UPDATE_OBJ | jq '. += {"salt": "'$SALT'", "hashedPassword": "'$HASHED_PW'"}')
fi

if [ ! -z "$NEW_PHONE" ]; then
    UPDATE_OBJ=$(echo $UPDATE_OBJ | jq '. += {"phoneNumber": "'$NEW_PHONE'"}')
fi

# Update user in MongoDB and capture the output
RESULT=$(mongosh "$MONGO_URI" --quiet --eval "
var result = db.users.updateOne(
  { username: '$EMAIL' },
  { \$set: $UPDATE_OBJ }
);
JSON.stringify(result);
")

# Extract matchedCount and modifiedCount from the result
MATCHED_COUNT=$(echo "$RESULT" | jq -r '.matchedCount')
MODIFIED_COUNT=$(echo "$RESULT" | jq -r '.modifiedCount')

# Check the result and provide appropriate output
if [ "$MATCHED_COUNT" = "0" ]; then
    echo -e "${RED}Error: No user found with email: $EMAIL${NC}"
    exit 1
elif [ "$MODIFIED_COUNT" = "1" ]; then
    echo -e "${GREEN}Success: User data updated for email: $EMAIL${NC}"
    [ ! -z "$NEW_PASSWORD" ] && echo -e "${GREEN}Password updated${NC}"
    [ ! -z "$NEW_PHONE" ] && echo -e "${GREEN}Phone number updated to $NEW_PHONE${NC}"
    exit 0
else
    echo -e "${YELLOW}Warning: User found but no data was updated. It might be the same as the current data.${NC}"
    exit 2
fi
