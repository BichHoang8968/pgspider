SUPPORT_STORAGE = s3 azure gcs

CXX = g++
CXXFLAGS = -std=c++17

# init data tool and objstorage_fdw source code have different build flag, so

SRCS_YES := localStorage.cpp storage.cpp
SRCS_$(if $(findstring azure,$(SUPPORT_STORAGE)),YES,NO) += azureStorage.cpp
LDLIBS_$(if $(findstring azure,$(SUPPORT_STORAGE)),YES,NO) += -lazure-storage-blobs -lazure-storage-common -lazure-core -lcurl -lssl -lcrypto -lpthread -lxml2 -lz -llzma -ldl
CXXFLAGS_$(if $(findstring azure,$(SUPPORT_STORAGE)),YES,NO) += -DSUPPORT_AZURE

SRCS_$(if $(findstring gcs,$(SUPPORT_STORAGE)),YES,NO) += gcpStorage.cpp
LDLIBS_$(if $(findstring gcs,$(SUPPORT_STORAGE)),YES,NO) += -labsl_base -labsl_throw_delegate -labsl_bad_any_cast_impl -labsl_bad_optional_access -labsl_bad_variant_access -lgoogle_cloud_cpp_common -lgoogle_cloud_cpp_storage
CXXFLAGS_$(if $(findstring gcs,$(SUPPORT_STORAGE)),YES,NO) += -DSUPPORT_GCS

SRCS_$(if $(findstring s3,$(SUPPORT_STORAGE)),YES,NO) += s3Storage.cpp'
LDLIBS_$(if $(findstring s3,$(SUPPORT_STORAGE)),YES,NO) += -laws-cpp-sdk-core -laws-cpp-sdk-s3 -lboost_iostreams
CXXFLAGS_$(if $(findstring s3,$(SUPPORT_STORAGE)),YES,NO) += -DSUPPORT_S3

LDLIBS += -lstdc++ $(LDLIBS_YES)
CXXFLAGS += $(CXXFLAGS_YES)

TARGET = prepareTestStorage
SRCS = \
prepareTestStorage.cpp \
$(SRCS_YES)

OBJS = $(addsuffix .o, $(basename $(SRCS)))

$(TARGET): $(OBJS)

#	$(CXX) $^ -o $@

.PHONY: clean

clean:
	$(RM) $(TARGET) $(OBJS)
