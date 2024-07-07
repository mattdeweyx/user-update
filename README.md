
# MongoDB User Data Update Tool

This tool allows authorized administrators to update user passwords and phone numbers in a MongoDB database.

## Description

The `user-update` script enables administrators to modify user data in the specified MongoDB database. It can update passwords (using a consistent hashing method) and phone numbers.

## Features

- Securely updates user passwords in the MongoDB database
- Updates user phone numbers
- Uses consistent password hashing method compatible with the main application
- Provides color-coded output for easy interpretation of results
- Handles various scenarios (user found/not found, data updated/not updated)

## Prerequisites

- Node.js
- MongoDB
- jq (command-line JSON processor)
- mongosh (MongoDB Shell)

## Usage

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/mongodb-user-update.git
   ```

2. Navigate to the directory:
   ```
   cd mongodb-user-update
   ```

3. Make the script executable:
   ```
   chmod +x user-update
   ```

4. Run the script with appropriate arguments:

   To update password:
   ```
   ./user-update user@example.com newpassword123
   ```

   To update phone number:
   ```
   ./user-update user@example.com --phone +1234567890
   ```

   To update both:
   ```
   ./user-update user@example.com newpassword123 --phone +1234567890
   ```

## Output

- Green: Success - Data updated
- Red: Error - User not found
- Yellow: Warning - User found but data not updated (possibly unchanged)

## Security Notice

This tool should only be used by authorized administrators. Keep it secure and use it responsibly in compliance with your organization's policies and relevant data protection laws.

## Contributing

Contributions to improve the script are welcome. Please feel free to submit a Pull Request.

## License

[MIT License](LICENSE)
