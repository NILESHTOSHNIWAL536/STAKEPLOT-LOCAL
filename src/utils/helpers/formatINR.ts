export function formatINR(value: number | string): string | number {
  let num = typeof value === 'number' ? value : Number(value);

  if (isNaN(num)) {
    return value; // return original invalid input
  }

  const [intPart, decimalPart] = num.toFixed(2).split('.');

  const lastThree = intPart.slice(-3);
  const otherNumbers = intPart.slice(0, -3);

  const formattedInt = otherNumbers.replace(/\B(?=(\d{2})+(?!\d))/g, ',') + (otherNumbers ? ',' : '') + lastThree;

  return `₹${formattedInt}.${decimalPart}`;
}

export default formatINR;
