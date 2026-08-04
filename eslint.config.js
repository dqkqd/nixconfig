import gitignore from "eslint-config-flat-gitignore";
import tseslint from "typescript-eslint";

export default tseslint.config(
  gitignore(),
  ...tseslint.configs.recommended,
  { files: ["**/*.ts"] },
);
