package soa.enrollmentservice.service;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import soa.enrollmentservice.client.CourseClient;
import soa.enrollmentservice.client.PaymentClient;
import soa.enrollmentservice.dto.CourseClientResponse;
import soa.enrollmentservice.dto.EnrollmentRequest;
import soa.enrollmentservice.dto.EnrollmentResponse;
import soa.enrollmentservice.dto.PaymentClientRequest;
import soa.enrollmentservice.exception.EnrollmentNotFoundException;
import soa.enrollmentservice.model.Enrollment;
import soa.enrollmentservice.repository.EnrollmentRepository;

@Service
public class EnrollmentService {

    private final EnrollmentRepository enrollmentRepository;
    private final CourseClient courseClient;
    private final PaymentClient paymentClient;

    @Value("${tuition.default-amount:500.00}")
    private BigDecimal defaultTuitionAmount;

    public EnrollmentService(EnrollmentRepository enrollmentRepository,
                             CourseClient courseClient,
                             PaymentClient paymentClient) {
        this.enrollmentRepository = enrollmentRepository;
        this.courseClient = courseClient;
        this.paymentClient = paymentClient;
    }

    // CREATE
    public EnrollmentResponse createEnrollment(EnrollmentRequest request) {

        // Validate course existence via Course Service
        CourseClientResponse course;
        try {
            course = courseClient.getCourseById(request.getCourseId());
        } catch (Exception e) {
            throw new RuntimeException("Course not found or Course Service unavailable for course ID: " + request.getCourseId(), e);
        }

        if (course == null) {
            throw new RuntimeException("Course not found with id: " + request.getCourseId());
        }

        // Capacity validation
        if (course.getCapacity() > 0) {
            long currentEnrolled = enrollmentRepository.countByCourseId(request.getCourseId());
            if (currentEnrolled >= course.getCapacity()) {
                throw new IllegalStateException("Course capacity reached. Maximum capacity is " + course.getCapacity());
            }
        }

        Enrollment enrollment = new Enrollment();

        enrollment.setStudentId(request.getStudentId());
        enrollment.setCourseId(request.getCourseId());
        enrollment.setStatus(request.getStatus());

        Enrollment savedEnrollment = enrollmentRepository.save(enrollment);

        // Initiate tuition payment via Payment Service
        try {
            paymentClient.createPayment(new PaymentClientRequest(
                    savedEnrollment.getId(),
                    defaultTuitionAmount,
                    "PENDING"
            ));
        } catch (Exception e) {
            System.err.println("Notice: Could not automatically initiate payment for enrollment " + savedEnrollment.getId() + ": " + e.getMessage());
        }

        return convertToResponse(savedEnrollment);
    }

    // READ ALL
    public List<EnrollmentResponse> getAllEnrollments() {

        List<Enrollment> enrollments = enrollmentRepository.findAll();

        return enrollments.stream()
                .map(this::convertToResponse)
                .toList();
    }

    // READ BY ID
    public EnrollmentResponse getEnrollmentById(Long id) {

        Enrollment enrollment = enrollmentRepository.findById(id)
                .orElseThrow(() ->
                        new EnrollmentNotFoundException("Enrollment not found"));

        return convertToResponse(enrollment);
    }

    // UPDATE
    public EnrollmentResponse updateEnrollment(
            Long id,
            EnrollmentRequest request) {

        Enrollment enrollment = enrollmentRepository.findById(id)
                .orElseThrow(() ->
                        new EnrollmentNotFoundException("Enrollment not found"));

        enrollment.setStudentId(request.getStudentId());
        enrollment.setCourseId(request.getCourseId());
        enrollment.setStatus(request.getStatus());

        Enrollment updatedEnrollment = enrollmentRepository.save(enrollment);

        return convertToResponse(updatedEnrollment);
    }

    // DELETE
    public void deleteEnrollment(Long id) {

        Enrollment enrollment = enrollmentRepository.findById(id)
                .orElseThrow(() ->
                        new EnrollmentNotFoundException("Enrollment not found"));

        enrollmentRepository.delete(enrollment);
    }

    // CONVERT ENTITY TO RESPONSE
    private EnrollmentResponse convertToResponse(Enrollment enrollment) {

        EnrollmentResponse response = new EnrollmentResponse();

        response.setId(enrollment.getId());
        response.setStudentId(enrollment.getStudentId());
        response.setCourseId(enrollment.getCourseId());
        response.setStatus(enrollment.getStatus());

        return response;
    }
}