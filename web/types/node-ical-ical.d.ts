declare module "node-ical/ical.js" {
  const ical: {
    parseICS: (input: string) => Record<string, unknown>;
  };
  export default ical;
}
