export const ErrorResponse: { success: boolean; message: string; data: object; error: object | string } = {
  success: false,
  message: 'Something went wrong',
  data: {},
  error: {},
};

export const SuccessResponse: { success: boolean; message: string; data: object; error: object | string } = {
  success: true,
  message: 'Successfully completed the request',
  data: {},
  error: {},
};
