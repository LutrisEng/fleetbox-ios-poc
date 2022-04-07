export function multiLineToSingleLine(multiline: string): string {
  return multiline
    .split("\n")
    .map((x) => x.replace(/^\s+/, ""))
    .filter((x) => x !== "")
    .join(" ");
}
