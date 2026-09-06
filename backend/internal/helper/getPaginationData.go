package helper

import (
	"barberstuff_backend/internal/dto"
	"math"
)

func GetPaginationData(page, limit, total int) dto.ResponsePagination {
	totalPages := int(math.Ceil(float64(total) / float64(limit)))
	return dto.ResponsePagination{
		Page:       page,
		Limit:      limit,
		TotalData:  total,
		TotalPages: totalPages,
	}
}
