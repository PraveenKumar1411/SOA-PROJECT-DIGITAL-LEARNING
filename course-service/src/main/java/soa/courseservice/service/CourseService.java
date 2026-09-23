package soa.courseservice.service;

import java.util.List;

import org.springframework.stereotype.Service;

import soa.courseservice.dto.CourseRequest;
import soa.courseservice.dto.CourseResponse;
import soa.courseservice.exception.CourseNotFoundException;
import soa.courseservice.model.Course;
import soa.courseservice.repository.CourseRepository;

@Service
public class CourseService {

    private final CourseRepository courseRepository;

    public CourseService(CourseRepository courseRepository) {
        this.courseRepository = courseRepository;
    }

    // CREATE
    public CourseResponse createCourse(CourseRequest request) {

        Course course = new Course();

        course.setTitle(request.getTitle());
        course.setInstructor(request.getInstructor());
        course.setCapacity(request.getCapacity());

        Course savedCourse = courseRepository.save(course);

        return convertToResponse(savedCourse);
    }

    // READ ALL
    public List<CourseResponse> getAllCourses() {

        List<Course> courses = courseRepository.findAll();

        return courses.stream()
                .map(this::convertToResponse)
                .toList();
    }

    // READ BY ID
    public CourseResponse getCourseById(Long id) {

        Course course = courseRepository.findById(id)
                .orElseThrow(() ->
                        new CourseNotFoundException("Course not found"));

        return convertToResponse(course);
    }

    // UPDATE
    public CourseResponse updateCourse(Long id, CourseRequest request) {

        Course course = courseRepository.findById(id)
                .orElseThrow(() ->
                        new CourseNotFoundException("Course not found"));

        course.setTitle(request.getTitle());
        course.setInstructor(request.getInstructor());
        course.setCapacity(request.getCapacity());

        Course updatedCourse = courseRepository.save(course);

        return convertToResponse(updatedCourse);
    }

    // DELETE
    public void deleteCourse(Long id) {

        Course course = courseRepository.findById(id)
                .orElseThrow(() ->
                        new CourseNotFoundException("Course not found"));

        courseRepository.delete(course);
    }

    // CONVERT COURSE TO RESPONSE
    private CourseResponse convertToResponse(Course course) {

        CourseResponse response = new CourseResponse();

        response.setId(course.getId());
        response.setTitle(course.getTitle());
        response.setInstructor(course.getInstructor());
        response.setCapacity(course.getCapacity());

        return response;
    }
}