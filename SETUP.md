# Setup Guide for OBS Random Questions Plugin

This guide will help you set up and configure the OBS Random Questions Script.

## Installation

1. Download the `questions.lua` script from this repository.
2. Place the `questions.lua` file in your OBS scripts folder:
   - Windows: `C:\Program Files\obs-studio\data\obs-plugins\frontend-tools\scripts\`
   - macOS: `/Library/Application Support/obs-studio/plugins/frontend-tools/scripts/`
   - Linux: `~/.config/obs-studio/plugins/frontend-tools/scripts/`
3. In OBS, go to Tools > Scripts.
4. Click the "+" button in the Scripts window.
5. Navigate to the folder where you placed `questions.lua` and select it.
6. The "Random Questions" script should now appear in your Scripts list.

## Configuration

1. In the Scripts window, select the "Random Questions" script.
2. Choose a text source from the dropdown menu. This is where the questions will be displayed. 
3. (Optional) Enable and adjust the auto-change interval. This determines how often a new question will appear automatically.
4. (Optional) Set up hotkeys for cycling through questions. This can be done in OBS Settings > Hotkeys.

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

## Troubleshooting

If you encounter any issues:

1. Make sure the script is properly loaded in OBS.
2. Check that you've selected a valid text source.
3. Restart OBS and try reloading the script.

For further assistance, please open an issue on the GitHub repository.
