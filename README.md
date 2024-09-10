# OBS Random Questions Script

This Lua script for OBS (Open Broadcaster Software) generates random questions and allows cycling through question history. It's perfect for streamers who want to engage their audience with interesting questions during their broadcasts.

## Features

- Generates random questions from a predefined list
- Allows cycling through question history (next and previous)
- Automatically changes questions at a set interval
- Changes question when the source is reactivated
- Supports hotkeys for quick question changes
- Customizable auto-change interval

## Installation

1. Download the `random_questions.lua` file from this repository.
2. In OBS, go to Tools > Scripts
3. Click the "+" button and select the downloaded `random_questions.lua` file
4. Configure the script settings in the "Scripts" window

## Usage

- Set up a Text (GDI+) source in your scene
- In the script properties, select your text source
- Use the provided buttons or set up hotkeys to change questions
- Adjust the auto-change interval as needed
- The question will change automatically when you reactivate the source (e.g., by hiding and showing it)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.