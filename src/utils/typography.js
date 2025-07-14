import Typography from "typography";
import sutroTheme from "typography-theme-sutro";

sutroTheme.overrideThemeStyles = () => ({
  a: {
    color: "#4b0082",
  },
});

const typography = new Typography(sutroTheme);

export default typography;
export const rhythm = typography.rhythm;
