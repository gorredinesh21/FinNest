package com.finnest.app.controllers;


import com.finnest.app.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
public class IndexController {

    @Autowired
    private UserRepository userRepository;

    @GetMapping("/")
    public ResponseEntity<Object> getIndex() {
        java.nio.file.Path index = java.nio.file.Paths.get("/app/web/index.html");
        if (java.nio.file.Files.exists(index)) {
            return ResponseEntity.ok()
                .header("Content-Type", "text/html")
                .body(new org.springframework.core.io.FileSystemResource(index));
        }
        return ResponseEntity.ok("FinNest API is running.");
    }

    @GetMapping("/verify")
    public ResponseEntity<?> getVerify(@RequestParam("token")String token, @RequestParam("code")String code){

        //Get Token In Database
        String dbToken = userRepository.checkToken(token);

        //Check If Token Is Valid:
        if(dbToken == null){
            return ResponseEntity.badRequest().body("This session has expire.");
        }
        //End of Check If Token is valid.

        //Update and Verify Account
        userRepository.verifyAccount(token,code);
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Verification success." );
        System.out.println("In Verify Account Controller");
        return ResponseEntity.ok(response);


    }
}
