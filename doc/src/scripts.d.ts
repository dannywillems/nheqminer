// Allow importing shell scripts as raw strings (webpack asset/source).
// See the scripts-raw-loader plugin in docusaurus.config.ts.
declare module '*.sh' {
  const content: string;
  export default content;
}
