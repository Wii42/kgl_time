
# KGL Time

KGL Time is a simple time tracking app designed to help users manage their work hours efficiently. Developed with Flutter, the app allows users to enter and store their work hours locally on their devices without collecting any personal information.

## Privacy Policy

KGL Time does not collect, store, or share any personal information from its users. For more details on how user data is handled, please refer to the [PRIVACY.md](PRIVACY.md) file.

## License

KGL Time is licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.html). You can view the terms and conditions in the [LICENSE.md](LICENSE.md) file.

## Features

- **User-friendly Interface**: Easy to navigate and track work hours.
- **Local Storage**: All entered data is stored locally on the device, ensuring user privacy.
- **No Registration Required**: Users can start tracking time immediately without the need for accounts or logins.

## Platform Compatibility

The app can, in principle, be built for all platforms that Flutter provides, except for the web. However, the application has only been tested on **Windows** and **Android**.

## Getting Started

1. **Clone the Repository**: Use the following command to clone the repository:
   ```bash
   git clone https://github.com/Wii42/kgl-time.git
   ```

2. **Install Dependencies**: Navigate to the project directory and install the required dependencies:
   ```bash
   cd kgl-time
   flutter pub get
   ```

3. **Run the Project**: Start the application using:
   ```bash
   flutter run
   ```
   or build the APK for Android:
   ```bash
   flutter build apk
   ```
   
## Changelog
#### v0.3.1
- Added trash bin, allowing users to recover deleted work entries for 30 days
- Added animations on adding/deleting work entries, to give better visual feedback to the user
- Minor bug fixes and improvements

#### v0.3.0
- Added a navigation bar
- Minor bug fixes and adjustments

#### v0.2.3
- Improved the error message text for excessively large numbers (see v0.2.2)

#### v0.2.2
- Fixed an issue where very large numbers entered for work duration on the “New Entry” page appeared as negative values


#### v0.2.0
- Categories can now be added directly in the time entry slider

#### v0.1.1
- Minor UI improvements

#### v0.1.0
- Initial release
## Contact

For any questions about KGL Time or this project, please reach out via the provided email address:

- **Lukas Künzi**: [wi42.dev@gmail.com](mailto:wi42.dev@gmail.com)
- **Website**: [https://wi42.dev](https://wi42.dev)
