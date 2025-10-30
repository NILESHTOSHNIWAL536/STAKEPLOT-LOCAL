function formatINR(value) {
  if (typeof value !== "number") value = Number(value);
  if (isNaN(value)) return value;

  const [intPart, decimalPart] = value.toFixed(2).split(".");
  let lastThree = intPart.slice(-3);
  const otherNumbers = intPart.slice(0, -3);

  const formattedInt =
    otherNumbers.replace(/\B(?=(\d{2})+(?!\d))/g, ",") +
    (otherNumbers ? "," : "") +
    lastThree;

  return `₹${formattedInt}.${decimalPart}`;
}


module.exports = formatINR;