package dto

type PresignRequest struct {
	FileName    string `json:"file_name" binding:"required"`
	ContentType string `json:"content_type" binding:"required,oneof=image/png image/jpeg image/webp image/gif"`
	FileSize    int64  `json:"file_size" binding:"required,min=1,max=5242880"`
}

type PresignResponse struct {
	UploadURL string `json:"upload_url"`
	ObjectKey string `json:"object_key"`
}
