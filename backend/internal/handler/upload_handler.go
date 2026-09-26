package handler

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/lib"
	"net/http"
	"path/filepath"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type UploadHandler struct{}

func NewUploadHandler() *UploadHandler {
	return &UploadHandler{}
}

func (h *UploadHandler) GetPresignedURL(ctx *gin.Context) {
	var req dto.PresignRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	ext := strings.ToLower(filepath.Ext(req.FileName))

	contentTypeByExt := map[string]string{
		".jpg":  "image/jpeg",
		".jpeg": "image/jpeg",
		".png":  "image/png",
		".webp": "image/webp",
		".gif":  "image/gif",
	}

	expectedContentType, ok := contentTypeByExt[ext]
	if !ok {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Extensi file tidak didukung",
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	if expectedContentType != req.ContentType {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "extension file tidak sesuai dengan content type",
			StatusCode: http.StatusBadRequest,
		})

		return
	}

	const MaxFileSize = 5 * 1024 * 1024
	if req.FileSize < 1 {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "minimum upload file adalah 1 byte",
			StatusCode: http.StatusBadRequest,
		})

		return
	}

	if req.FileSize > MaxFileSize {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "maximum upload file adalah 5 mb",
			StatusCode: http.StatusBadRequest,
		})

		return
	}

	objectKey := "temp/" + time.Now().Format("2006/01") + "/" + uuid.New().String() + ext

	uploadURL, err := lib.GenereatePresignedUploadURL(objectKey, req.ContentType)
	if err != nil {
		helper.Logger("generate url uppload", "upload_handler.go", err)
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Gagal generate URL upload.",
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[dto.PresignResponse]{
		Data: dto.PresignResponse{
			UploadURL: uploadURL,
			ObjectKey: objectKey,
		},
		Message:    "Success create presign URL",
		StatusCode: http.StatusCreated,
	})
}
