export const ErrorResponse: { success: boolean; message: string; data: object; error: object } = {
  success: false,
  message: 'Something went wrong',
  data: {},
  error: {},
};

export const SuccessResponse: { success: boolean; message: string; data: object; error: object } = {
  success: true,
  message: 'Successfully completed the request',
  data: {},
  error: {},
};
