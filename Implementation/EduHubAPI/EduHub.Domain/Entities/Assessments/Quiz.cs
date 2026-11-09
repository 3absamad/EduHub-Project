using EduHub.Domain.Entities.Course_Managment;
using System;
using System.Collections.Generic;
using System.Text;

namespace EduHub.Domain.Entities.Assessments
{
    public class Quiz
    {
        public int QuizId { get; set; }
        public int LessonId { get; set; }
        public string Title { get; set; } = string.Empty;
        public int PassingScore { get; set; }
        public int TimeLimitMinutes { get; set; }

        public Lesson Lesson { get; set; } = null!;
        public ICollection<Question> Questions { get; set; } = new List<Question>();    
        public ICollection<QuizAttempt> Attempts { get; set; }  = new List<QuizAttempt>();
    }

}
