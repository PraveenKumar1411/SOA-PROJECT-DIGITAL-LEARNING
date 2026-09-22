package soa.authservice.service;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import soa.authservice.dto.AuthResponse;
import soa.authservice.dto.LoginRequest;
import soa.authservice.dto.RegisterRequest;
import soa.authservice.exception.UserAlreadyExistsException;
import soa.authservice.model.AuthUser;
import soa.authservice.repository.AuthUserRepository;
import soa.authservice.security.JwtService;

@Service
public class AuthService {

    private final AuthUserRepository authUserRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthService(AuthUserRepository authUserRepository,
                       PasswordEncoder passwordEncoder,
                       JwtService jwtService) {
        this.authUserRepository = authUserRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    public AuthResponse register(RegisterRequest request) {

        if (authUserRepository.findByUsername(request.getUsername()).isPresent()) {
            throw new UserAlreadyExistsException("Username already exists");
        }

        AuthUser user = new AuthUser();

        user.setUsername(request.getUsername());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole(request.getRole());

        AuthUser savedUser = authUserRepository.save(user);

        return createResponse(savedUser);
    }

    public AuthResponse login(LoginRequest request) {

        AuthUser user = authUserRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new RuntimeException("Invalid username or password"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new RuntimeException("Invalid username or password");
        }

        return createResponse(user);
    }

    private AuthResponse createResponse(AuthUser user) {

        String token = jwtService.generateToken(
                user.getUsername(),
                user.getRole()
        );

        AuthResponse response = new AuthResponse();

        response.setToken(token);
        response.setUsername(user.getUsername());
        response.setRole(user.getRole());

        return response;
    }
}