// const SuccessResponse = {
//   status: 'success',
//   data: null,
// };

// const ErrorResponse = {
//   status: 'error',
//   error: null,
// };

// module.exports = {
//   SuccessResponse,
//   ErrorResponse,
// };
// // --- IGNORE ---

export interface ISuccessResponse<T = any> {
  status: 'success';
  data: T | null;
}

export interface IErrorResponse {
  status: 'error';
  error: any;
}

export const SuccessResponse: ISuccessResponse = {
  status: 'success',
  data: null,
};

export const ErrorResponse: IErrorResponse = {
  status: 'error',
  error: null,
};
