# event_manager

This project is a simple event management tool designed to read data from a CSV file and perform various operations on it, including cleaning up zipcodes and phone numbers, looking up the legislators for an address using the Google Civic Information API, generating thank-you letters, and analyzing peak registration times.

## Setup

1. Install Ruby on your computer if it's not already installed.

2. Clone the repository to your computer.

   ```
   git clone https://github.com/your-username/event_manager.git
   cd event_manager
   ```

3. Install the required gems.

   ```
   bundle install
   ```

4. Obtain a Google Civic Information API key by following the instructions [here](https://developers.google.com/civic-information/docs/v2/getting_started).

5. Replace the API key placeholder in the `legislators_by_zipcode` method with your own API key.

   ```
   civic_info.key = 'YOUR_API_KEY_HERE'
   ```

6. Place your CSV file in the project directory and name it `event_attendees.csv`.

## Usage

1. Run the program by typing `ruby event_manager.rb` in the terminal.

2. The program will clean up the zipcodes and phone numbers, generate thank-you letters, and print out the peak registration time.

3. The generated thank-you letters will be stored in the `output` directory.

4. You can modify the `form_letter.erb` file to change the format of the thank-you letters.

5. You can modify the `get_peak_hour` method to perform different analyses based on the registration times.
