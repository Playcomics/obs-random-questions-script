# Setup Guide for OBS Random Questions Plugin

This guide will help you set up and configure the OBS Random Questions Plugin.

## Installation

1. Download the `questions.lua` script from this repository.
2. In OBS, go to Tools > Scripts.
3. Click the "+" button and select the `questions.lua` file.

## Configuration

1. In the Scripts window, select the "Random Questions" script.
2. Choose a text source from the dropdown menu.
3. (Optional) Adjust the auto-change interval.
4. (Optional) Set up hotkeys for cycling through questions.

## Adding Custom Questions

To add your own questions:

1. Open the `questions.lua` file in a text editor.
2. Locate the `questions` table near the top of the file.
3. Add your questions as new entries in the table. For example:

   ```lua
   questions = {
       "What's your favorite movie?",
       "If you could have any superpower, what would it be?",
       "What's the best advice you've ever received?",
       -- Add your new questions here
       "What's your dream vacation destination?",
       "If you could have dinner with any historical figure, who would it be?",
   }
   ```

4. Save the file and reload the script in OBS.

Remember to keep your questions appropriate for your audience and stream content.

## Troubleshooting

If you encounter any issues:

1. Make sure the script is properly loaded in OBS.
2. Check that you've selected a valid text source.
3. Restart OBS and try reloading the script.

For further assistance, please open an issue on the GitHub repository.
