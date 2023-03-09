// This file is part of OpenCV project.
// It is subject to the license terms in the LICENSE file found in the top-level directory
// of this distribution and at http://opencv.org/license.html.
// Copyright (c) 2020-2021 darkliang wangberlinT Certseeds

#ifndef __OPENCV_BARCODE_ABS_DECODER_HPP__
#define __OPENCV_BARCODE_ABS_DECODER_HPP__

#include <opencv2/barcode.hpp>

namespace cv {
namespace barcode {
using std::string;
using std::vector;
constexpr static uchar BLACK = std::numeric_limits<uchar>::min();
// WHITE elemental area is 0xff
constexpr static uchar WHITE = std::numeric_limits<uchar>::max();


struct Result
{
    std::string result;
    BarcodeType format = BarcodeType::NONE;

    Result() = default;

    Result(const std::string &_result, BarcodeType _format)
    {
        result = _result;
        format = _format;
    }
};

struct Counter
{
    std::vector<int> pattern;
    uint sum;

    explicit Counter(const vector<int> &_pattern)
    {
        pattern = _pattern;
        sum = 0;
    }
};

class AbsDecoder
{
public:
    virtual std::pair<Result, float> decodeROI(const Mat &bar_img) const = 0;

    virtual ~AbsDecoder() = default;

protected:
    virtual Result decode(const vector<uchar> &data) const = 0;

    virtual bool isValid(const string &result) const = 0;

    size_t bits_num{};
    size_t digit_number{};
};

void cropROI(const Mat &_src, Mat &_dst, const std::vector<Point2f> &rect);

void fillCounter(const std::vector<uchar> &row, uint start, Counter &counter);

constexpr static uint INTEGER_MATH_SHIFT = 8;
constexpr static uint PATTERN_MATCH_RESULT_SCALE_FACTOR = 1 << INTEGER_MATH_SHIFT;

uint patternMatch(const Counter &counters, const std::vector<int> &pattern, uint maxIndividual);
}
} // namespace cv

#endif //! __OPENCV_BARCODE_ABS_DECODER_HPP__
