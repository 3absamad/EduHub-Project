/*==================================================================================================
  PROJECT       : EduHub – Online Learning Platform (DEPI Graduation Project)
  SCRIPT        : EduHub_Database.sql
  TARGET DBMS   : Microsoft SQL Server (2019 / 2022 / Azure SQL Database)
  TOOLING       : SQL Server Management Studio (SSMS) & Entity Framework Core
  SOURCE SCHEMA : Approved Physical Relational Schema (27 Tables, 203 Physical Columns, 46 FKs)
  DESCRIPTION   : Complete, executable T-SQL implementation translating the approved Draw.io
                  relational schema into SQL Server tables, keys, constraints, and indexes.
==================================================================================================*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

/*==================================================================================================
  SECTION 1: DATABASE CREATION (OPTIONAL / SEPARABLE)
  Purpose: Creates the [EduHubDB] database if it does not already exist and switches context.
           If deploying to a pre-provisioned Azure SQL Database, you may skip the CREATE DATABASE
           statement and execute from USE [EduHubDB] onward.
==================================================================================================*/
USE [master];
GO

IF DB_ID(N'EduHubDB') IS NULL
BEGIN
    CREATE DATABASE [EduHubDB];
END;
GO

USE [EduHubDB];
GO

/*==================================================================================================
  SECTION 2: TABLE CREATION
  Purpose: Creates all 27 approved physical tables in dependency order with exact data types,
           IDENTITY specifications, and NULL / NOT NULL rules.
           Note: Primary Keys, Foreign Keys, Unique Constraints, Check Constraints, Default
           Constraints, and Indexes are applied in Sections 3 through 8 for clear modularity.
==================================================================================================*/

-- 1. Roles: Stores system authorization roles (Student, Instructor, Admin).
CREATE TABLE [dbo].[Roles]
(
    [RoleId]      INT            IDENTITY(1,1) NOT NULL,
    [RoleName]    NVARCHAR(100)                NOT NULL,
    [Description] NVARCHAR(500)                NULL,
    [CreatedAt]   DATETIME2(3)                 NOT NULL
);
GO

-- 2. Users: Stores registered account holders (Students, Instructors, Admins).
-- Security Rule: Plaintext passwords are never stored; only cryptographic PasswordHash values.
CREATE TABLE [dbo].[Users]
(
    [UserId]            INT             IDENTITY(1,1) NOT NULL,
    [FullName]          NVARCHAR(150)                 NOT NULL,
    [UserName]          NVARCHAR(100)                 NOT NULL,
    [Email]             NVARCHAR(256)                 NOT NULL,
    [PasswordHash]      NVARCHAR(512)                 NOT NULL,
    [Bio]               NVARCHAR(2000)                NULL,
    [ProfilePictureUrl] NVARCHAR(1000)                NULL,
    [IsActive]          BIT                           NOT NULL,
    [CreatedAt]         DATETIME2(3)                  NOT NULL,
    [UpdatedAt]         DATETIME2(3)                  NULL
);
GO

-- 3. Categories: Stores course catalog classification categories managed by Administrators.
CREATE TABLE [dbo].[Categories]
(
    [CategoryId]  INT            IDENTITY(1,1) NOT NULL,
    [Name]        NVARCHAR(120)                NOT NULL,
    [Description] NVARCHAR(500)                NULL,
    [IsActive]    BIT                          NOT NULL,
    [CreatedAt]   DATETIME2(3)                 NOT NULL,
    [UpdatedAt]   DATETIME2(3)                 NULL
);
GO

-- 4. SupportArticles: Stores approved support documentation grounding the AI Support Chatbot.
CREATE TABLE [dbo].[SupportArticles]
(
    [ArticleId]     INT            IDENTITY(1,1) NOT NULL,
    [TopicCategory] NVARCHAR(100)                NOT NULL,
    [Title]         NVARCHAR(200)                NOT NULL,
    [Content]       NVARCHAR(MAX)                NOT NULL,
    [IsApproved]    BIT                          NOT NULL,
    [UpdatedAt]     DATETIME2(3)                 NOT NULL
);
GO

-- 5. UserRoles: Junction table resolving the M:N relationship between Users and Roles.
CREATE TABLE [dbo].[UserRoles]
(
    [UserId]     INT          NOT NULL,
    [RoleId]     INT          NOT NULL,
    [AssignedAt] DATETIME2(3) NOT NULL
);
GO

-- 6. PlatformSettings: Stores configurable platform-wide key-value parameters (e.g., AI limits, fee %).
CREATE TABLE [dbo].[PlatformSettings]
(
    [SettingId]        INT            IDENTITY(1,1) NOT NULL,
    [UpdatedByAdminId] INT                          NULL,
    [SettingKey]       VARCHAR(100)                 NOT NULL,
    [SettingValue]     NVARCHAR(2000)               NOT NULL,
    [DataType]         VARCHAR(50)                  NOT NULL,
    [Description]      NVARCHAR(500)                NULL,
    [UpdatedAt]        DATETIME2(3)                 NOT NULL
);
GO

-- 7. Courses: Stores instructor-created courses, pricing, difficulty, and admin approval status.
-- Note on 3NF Derived Attributes: AverageRating and TotalReviews are derived dynamically from
-- [dbo].[CourseReviews] rather than stored redundantly as physical columns.
CREATE TABLE [dbo].[Courses]
(
    [CourseId]          INT             IDENTITY(1,1) NOT NULL,
    [InstructorId]      INT                           NOT NULL,
    [CategoryId]        INT                           NOT NULL,
    [ReviewedByAdminId] INT                           NULL,
    [Title]             NVARCHAR(200)                 NOT NULL,
    [Description]       NVARCHAR(MAX)                 NOT NULL,
    [ThumbnailUrl]      NVARCHAR(1000)                NULL,
    [Price]             DECIMAL(10,2)                 NOT NULL,
    [IsFree]            BIT                           NOT NULL,
    [DifficultyLevel]   VARCHAR(30)                   NOT NULL,
    [Status]            VARCHAR(30)                   NOT NULL,
    [RejectionReason]   NVARCHAR(1000)                NULL,
    [SubmittedAt]       DATETIME2(3)                  NULL,
    [PublishedAt]       DATETIME2(3)                  NULL,
    [CreatedAt]         DATETIME2(3)                  NOT NULL
);
GO

-- 8. CourseSections: Stores ordered curriculum modules/sections belonging to a specific Course.
CREATE TABLE [dbo].[CourseSections]
(
    [SectionId]   INT             IDENTITY(1,1) NOT NULL,
    [CourseId]    INT                           NOT NULL,
    [Title]       NVARCHAR(200)                 NOT NULL,
    [Description] NVARCHAR(1000)                NULL,
    [OrderIndex]  INT                           NOT NULL,
    [CreatedAt]   DATETIME2(3)                  NOT NULL,
    [UpdatedAt]   DATETIME2(3)                  NULL
);
GO

-- 9. Lessons: Stores individual lessons within a CourseSection.
-- Security & Storage Rule: Raw video binaries are never stored in SQL Server; VideoBlobUrl stores
-- the Azure Blob Storage reference URI alongside video metadata and text/transcripts.
CREATE TABLE [dbo].[Lessons]
(
    [LessonId]             INT             IDENTITY(1,1) NOT NULL,
    [SectionId]            INT                           NOT NULL,
    [Title]                NVARCHAR(200)                 NOT NULL,
    [ContentText]          NVARCHAR(MAX)                 NULL,
    [TranscriptText]       NVARCHAR(MAX)                 NULL,
    [VideoBlobUrl]         NVARCHAR(1000)                NULL,
    [VideoDurationSeconds] INT                           NULL,
    [VideoSizeBytes]       BIGINT                        NULL,
    [VideoFormat]          VARCHAR(30)                   NULL,
    [OrderIndex]           INT                           NOT NULL,
    [IsRequired]           BIT                           NOT NULL,
    [CreatedAt]            DATETIME2(3)                  NOT NULL
);
GO

-- 10. LessonSummaries: Stores AI-generated lesson summaries (1:0..1 with Lessons).
CREATE TABLE [dbo].[LessonSummaries]
(
    [SummaryId]            INT           IDENTITY(1,1) NOT NULL,
    [LessonId]             INT                         NOT NULL,
    [SummaryText]          NVARCHAR(MAX)               NOT NULL,
    [SourceTranscriptHash] CHAR(64)                    NOT NULL,
    [GeneratedAt]          DATETIME2(3)                NOT NULL
);
GO

-- 11. LessonSummaryKeyPoints: 1NF child table storing atomic ordered key points for a LessonSummary.
CREATE TABLE [dbo].[LessonSummaryKeyPoints]
(
    [KeyPointId]   INT           IDENTITY(1,1) NOT NULL,
    [SummaryId]    INT                         NOT NULL,
    [KeyPointText] NVARCHAR(500)               NOT NULL,
    [OrderIndex]   INT                         NOT NULL
);
GO

-- 12. CourseAnnouncements: Stores announcements published by an Instructor for a Course.
CREATE TABLE [dbo].[CourseAnnouncements]
(
    [AnnouncementId] INT           IDENTITY(1,1) NOT NULL,
    [CourseId]       INT                         NOT NULL,
    [InstructorId]   INT                         NOT NULL,
    [Title]          NVARCHAR(200)               NOT NULL,
    [Message]        NVARCHAR(MAX)               NOT NULL,
    [PublishedAt]    DATETIME2(3)                NOT NULL
);
GO

-- 13. Notifications: Stores user-targeted alerts for enrollments, payments, milestones, and announcements.
CREATE TABLE [dbo].[Notifications]
(
    [NotificationId]   INT            IDENTITY(1,1) NOT NULL,
    [RecipientUserId]  INT                          NOT NULL,
    [AnnouncementId]   INT                          NULL,
    [Title]            NVARCHAR(200)                NOT NULL,
    [Message]          NVARCHAR(1000)               NOT NULL,
    [NotificationType] VARCHAR(50)                  NOT NULL,
    [TargetUrl]        NVARCHAR(500)                NULL,
    [IsRead]           BIT                          NOT NULL,
    [ReadAt]           DATETIME2(3)                 NULL,
    [CreatedAt]        DATETIME2(3)                 NOT NULL
);
GO

-- 14. Coupons: Stores promotional discount codes (platform-wide or course-specific).
-- Note on 3NF Derived Attribute: CurrentUsageCount is derived dynamically from succeeded rows
-- in [dbo].[Payments] where CouponId matches.
CREATE TABLE [dbo].[Coupons]
(
    [CouponId]      INT           IDENTITY(1,1) NOT NULL,
    [CourseId]      INT                         NULL,
    [Code]          VARCHAR(50)                 NOT NULL,
    [DiscountType]  VARCHAR(20)                 NOT NULL,
    [DiscountValue] DECIMAL(10,2)               NOT NULL,
    [ExpiryDate]    DATETIME2(3)                NULL,
    [MaxUsageCount] INT                         NULL,
    [IsActive]      BIT                         NOT NULL,
    [CreatedAt]     DATETIME2(3)                NOT NULL
);
GO

-- 15. Enrollments: Tracks student enrollments in courses (free or paid).
-- Note on 3NF Derived Attribute: ProgressPercentage is derived dynamically from completed
-- required lessons in [dbo].[LessonProgress].
CREATE TABLE [dbo].[Enrollments]
(
    [EnrollmentId] INT          IDENTITY(1,1) NOT NULL,
    [StudentId]    INT                        NOT NULL,
    [CourseId]     INT                        NOT NULL,
    [Status]       VARCHAR(30)                NOT NULL,
    [IsCompleted]  BIT                        NOT NULL,
    [EnrolledAt]   DATETIME2(3)               NOT NULL,
    [CompletedAt]  DATETIME2(3)               NULL
);
GO

-- 16. Payments: Tracks Stripe checkout transactions, revenue splits, and webhook idempotency.
-- Security Rule: Raw credit card numbers/CVVs are never stored; only Stripe session/intent/event IDs.
CREATE TABLE [dbo].[Payments]
(
    [PaymentId]                INT           IDENTITY(1,1) NOT NULL,
    [StudentId]                INT                         NOT NULL,
    [CourseId]                 INT                         NOT NULL,
    [EnrollmentId]             INT                         NULL,
    [CouponId]                 INT                         NULL,
    [OriginalAmount]           DECIMAL(10,2)               NOT NULL,
    [DiscountAmount]           DECIMAL(10,2)               NOT NULL,
    [FinalAmount]              DECIMAL(10,2)               NOT NULL,
    [InstructorEarningsAmount] DECIMAL(10,2)               NOT NULL,
    [PlatformFeeAmount]        DECIMAL(10,2)               NOT NULL,
    [Currency]                 CHAR(3)                     NOT NULL,
    [PaymentStatus]            VARCHAR(30)                 NOT NULL,
    [StripeSessionId]          VARCHAR(255)                NOT NULL,
    [StripePaymentIntentId]    VARCHAR(255)                NULL,
    [StripeWebhookEventId]     VARCHAR(255)                NULL,
    [PaidAt]                   DATETIME2(3)                NULL
);
GO

-- 17. Certificates: Stores completion certificates and public verification codes (1:0..1 with Enrollments).
CREATE TABLE [dbo].[Certificates]
(
    [CertificateId]       INT            IDENTITY(1,1) NOT NULL,
    [EnrollmentId]        INT                          NOT NULL,
    [StudentId]           INT                          NOT NULL,
    [CourseId]            INT                          NOT NULL,
    [VerificationCode]    VARCHAR(64)                  NOT NULL,
    [StudentNameSnapshot] NVARCHAR(150)                NOT NULL,
    [CourseTitleSnapshot] NVARCHAR(200)                NOT NULL,
    [PdfBlobUrl]          NVARCHAR(1000)               NULL,
    [IssuedAt]            DATETIME2(3)                 NOT NULL
);
GO

-- 18. LessonProgress: Tracks per-lesson completion status and video resume position for an Enrollment.
CREATE TABLE [dbo].[LessonProgress]
(
    [LessonProgressId]  INT          IDENTITY(1,1) NOT NULL,
    [EnrollmentId]      INT                        NOT NULL,
    [LessonId]          INT                        NOT NULL,
    [IsCompleted]       BIT                        NOT NULL,
    [LastWatchedSecond] INT                        NOT NULL,
    [CompletedAt]       DATETIME2(3)               NULL,
    [UpdatedAt]         DATETIME2(3)               NOT NULL
);
GO

-- 19. Bookmarks: Stores student lesson bookmarks (at most one bookmark per student per lesson).
CREATE TABLE [dbo].[Bookmarks]
(
    [BookmarkId] INT          IDENTITY(1,1) NOT NULL,
    [StudentId]  INT                        NOT NULL,
    [LessonId]   INT                        NOT NULL,
    [CreatedAt]  DATETIME2(3)               NOT NULL
);
GO

-- 20. LessonNotes: Stores personal study notes taken by a student on a lesson (multiple allowed).
CREATE TABLE [dbo].[LessonNotes]
(
    [NoteId]                INT            IDENTITY(1,1) NOT NULL,
    [StudentId]             INT                          NOT NULL,
    [LessonId]              INT                          NOT NULL,
    [Content]               NVARCHAR(2000)               NOT NULL,
    [VideoTimestampSeconds] INT                          NULL,
    [CreatedAt]             DATETIME2(3)                 NOT NULL,
    [UpdatedAt]             DATETIME2(3)                 NULL
);
GO

-- 21. CourseReviews: Stores student course ratings (1..5) and reviews (one per student per course).
CREATE TABLE [dbo].[CourseReviews]
(
    [ReviewId]  INT            IDENTITY(1,1) NOT NULL,
    [CourseId]  INT                          NOT NULL,
    [StudentId] INT                          NOT NULL,
    [Rating]    TINYINT                      NOT NULL,
    [Comment]   NVARCHAR(2000)               NULL,
    [CreatedAt] DATETIME2(3)                 NOT NULL,
    [UpdatedAt] DATETIME2(3)                 NULL
);
GO

-- 22. Quizzes: Stores course or section assessments and passing thresholds.
CREATE TABLE [dbo].[Quizzes]
(
    [QuizId]                  INT            IDENTITY(1,1) NOT NULL,
    [CourseId]                INT                          NOT NULL,
    [SectionId]               INT                          NULL,
    [Title]                   NVARCHAR(200)                NOT NULL,
    [Description]             NVARCHAR(1000)               NULL,
    [PassingScore]            DECIMAL(5,2)                 NOT NULL,
    [IsRequiredForCertificate] BIT                         NOT NULL,
    [IsPublished]             BIT                          NOT NULL,
    [CreatedAt]               DATETIME2(3)                 NOT NULL
);
GO

-- 23. QuizQuestions: Stores ordered assessment questions belonging to a Quiz.
CREATE TABLE [dbo].[QuizQuestions]
(
    [QuestionId]   INT            IDENTITY(1,1) NOT NULL,
    [QuizId]       INT                          NOT NULL,
    [QuestionText] NVARCHAR(1500)               NOT NULL,
    [Points]       DECIMAL(5,2)                 NOT NULL,
    [OrderIndex]   INT                          NOT NULL,
    [IsRequired]   BIT                          NOT NULL
);
GO

-- 24. QuestionOptions: Stores ordered multiple-choice options for a QuizQuestion.
CREATE TABLE [dbo].[QuestionOptions]
(
    [OptionId]   INT            IDENTITY(1,1) NOT NULL,
    [QuestionId] INT                          NOT NULL,
    [OptionText] NVARCHAR(1000)               NOT NULL,
    [IsCorrect]  BIT                          NOT NULL,
    [OrderIndex] INT                          NOT NULL
);
GO

-- 25. QuizAttempts: Stores student quiz submissions and pass/fail outcomes.
-- Note on 3NF Derived Attribute: Score is derived dynamically by summing AwardedPoints in
-- [dbo].[QuizAttemptAnswers] for the AttemptId.
CREATE TABLE [dbo].[QuizAttempts]
(
    [AttemptId]    INT          IDENTITY(1,1) NOT NULL,
    [QuizId]       INT                        NOT NULL,
    [StudentId]    INT                        NOT NULL,
    [EnrollmentId] INT                        NOT NULL,
    [IsPassed]     BIT                        NOT NULL,
    [SubmittedAt]  DATETIME2(3)               NOT NULL
);
GO

-- 26. QuizAttemptAnswers: Stores individual question responses and awarded points per QuizAttempt.
CREATE TABLE [dbo].[QuizAttemptAnswers]
(
    [AttemptAnswerId]  INT          IDENTITY(1,1) NOT NULL,
    [AttemptId]        INT                        NOT NULL,
    [QuestionId]       INT                        NOT NULL,
    [SelectedOptionId] INT                        NOT NULL,
    [IsCorrect]        BIT                        NOT NULL,
    [AwardedPoints]    DECIMAL(5,2)               NOT NULL
);
GO

-- 27. AiUsageLogs: Audit and rate-limiting log for AI Summarization, AI Learning Assistant, and Support Chatbot.
CREATE TABLE [dbo].[AiUsageLogs]
(
    [UsageLogId]       BIGINT        IDENTITY(1,1) NOT NULL,
    [UserId]           INT                         NULL,
    [CourseId]         INT                         NULL,
    [LessonId]         INT                         NULL,
    [SupportArticleId] INT                         NULL,
    [ClientIdentifier] VARCHAR(128)                NOT NULL,
    [FeatureType]      VARCHAR(50)                 NOT NULL,
    [PromptText]       NVARCHAR(MAX)               NOT NULL,
    [ResponseText]     NVARCHAR(MAX)               NULL,
    [CreatedAt]        DATETIME2(3)                NOT NULL
);
GO

/*==================================================================================================
  SECTION 3: PRIMARY KEYS
  Purpose: Defines clustered Primary Key constraints on all 27 tables (26 single-column surrogate
           keys and 1 composite primary key on [dbo].[UserRoles]).
==================================================================================================*/

ALTER TABLE [dbo].[Roles]
    ADD CONSTRAINT [PK_Roles] PRIMARY KEY CLUSTERED ([RoleId] ASC);

ALTER TABLE [dbo].[Users]
    ADD CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED ([UserId] ASC);

ALTER TABLE [dbo].[Categories]
    ADD CONSTRAINT [PK_Categories] PRIMARY KEY CLUSTERED ([CategoryId] ASC);

ALTER TABLE [dbo].[SupportArticles]
    ADD CONSTRAINT [PK_SupportArticles] PRIMARY KEY CLUSTERED ([ArticleId] ASC);

ALTER TABLE [dbo].[UserRoles]
    ADD CONSTRAINT [PK_UserRoles] PRIMARY KEY CLUSTERED ([UserId] ASC, [RoleId] ASC);

ALTER TABLE [dbo].[PlatformSettings]
    ADD CONSTRAINT [PK_PlatformSettings] PRIMARY KEY CLUSTERED ([SettingId] ASC);

ALTER TABLE [dbo].[Courses]
    ADD CONSTRAINT [PK_Courses] PRIMARY KEY CLUSTERED ([CourseId] ASC);

ALTER TABLE [dbo].[CourseSections]
    ADD CONSTRAINT [PK_CourseSections] PRIMARY KEY CLUSTERED ([SectionId] ASC);

ALTER TABLE [dbo].[Lessons]
    ADD CONSTRAINT [PK_Lessons] PRIMARY KEY CLUSTERED ([LessonId] ASC);

ALTER TABLE [dbo].[LessonSummaries]
    ADD CONSTRAINT [PK_LessonSummaries] PRIMARY KEY CLUSTERED ([SummaryId] ASC);

ALTER TABLE [dbo].[LessonSummaryKeyPoints]
    ADD CONSTRAINT [PK_LessonSummaryKeyPoints] PRIMARY KEY CLUSTERED ([KeyPointId] ASC);

ALTER TABLE [dbo].[CourseAnnouncements]
    ADD CONSTRAINT [PK_CourseAnnouncements] PRIMARY KEY CLUSTERED ([AnnouncementId] ASC);

ALTER TABLE [dbo].[Notifications]
    ADD CONSTRAINT [PK_Notifications] PRIMARY KEY CLUSTERED ([NotificationId] ASC);

ALTER TABLE [dbo].[Coupons]
    ADD CONSTRAINT [PK_Coupons] PRIMARY KEY CLUSTERED ([CouponId] ASC);

ALTER TABLE [dbo].[Enrollments]
    ADD CONSTRAINT [PK_Enrollments] PRIMARY KEY CLUSTERED ([EnrollmentId] ASC);

ALTER TABLE [dbo].[Payments]
    ADD CONSTRAINT [PK_Payments] PRIMARY KEY CLUSTERED ([PaymentId] ASC);

ALTER TABLE [dbo].[Certificates]
    ADD CONSTRAINT [PK_Certificates] PRIMARY KEY CLUSTERED ([CertificateId] ASC);

ALTER TABLE [dbo].[LessonProgress]
    ADD CONSTRAINT [PK_LessonProgress] PRIMARY KEY CLUSTERED ([LessonProgressId] ASC);

ALTER TABLE [dbo].[Bookmarks]
    ADD CONSTRAINT [PK_Bookmarks] PRIMARY KEY CLUSTERED ([BookmarkId] ASC);

ALTER TABLE [dbo].[LessonNotes]
    ADD CONSTRAINT [PK_LessonNotes] PRIMARY KEY CLUSTERED ([NoteId] ASC);

ALTER TABLE [dbo].[CourseReviews]
    ADD CONSTRAINT [PK_CourseReviews] PRIMARY KEY CLUSTERED ([ReviewId] ASC);

ALTER TABLE [dbo].[Quizzes]
    ADD CONSTRAINT [PK_Quizzes] PRIMARY KEY CLUSTERED ([QuizId] ASC);

ALTER TABLE [dbo].[QuizQuestions]
    ADD CONSTRAINT [PK_QuizQuestions] PRIMARY KEY CLUSTERED ([QuestionId] ASC);

ALTER TABLE [dbo].[QuestionOptions]
    ADD CONSTRAINT [PK_QuestionOptions] PRIMARY KEY CLUSTERED ([OptionId] ASC);

ALTER TABLE [dbo].[QuizAttempts]
    ADD CONSTRAINT [PK_QuizAttempts] PRIMARY KEY CLUSTERED ([AttemptId] ASC);

ALTER TABLE [dbo].[QuizAttemptAnswers]
    ADD CONSTRAINT [PK_QuizAttemptAnswers] PRIMARY KEY CLUSTERED ([AttemptAnswerId] ASC);

ALTER TABLE [dbo].[AiUsageLogs]
    ADD CONSTRAINT [PK_AiUsageLogs] PRIMARY KEY CLUSTERED ([UsageLogId] ASC);
GO

/*==================================================================================================
  SECTION 4: FOREIGN KEYS
  Purpose: Enforces all 46 approved Foreign Key relationships.
           Referential Integrity Strategy:
           - Strict hierarchical composition children (UserRoles, LessonSummaries,
             LessonSummaryKeyPoints, QuestionOptions, QuizAttemptAnswers->QuizAttempts) use
             ON DELETE CASCADE where no multiple-cascade-path conflict exists.
           - Shared parent graphs (Users, Courses, CourseSections, Lessons, Enrollments, Quizzes,
             QuizQuestions) use ON DELETE NO ACTION (and ON DELETE SET NULL on isolated optional
             references) to prevent accidental mass deletion of financial/academic records and to
             avoid SQL Server Error 1785 (multiple cascade paths).
==================================================================================================*/

-- UserRoles (2 FKs)
ALTER TABLE [dbo].[UserRoles] WITH CHECK
    ADD CONSTRAINT [FK_UserRoles_Roles_RoleId]
    FOREIGN KEY ([RoleId]) REFERENCES [dbo].[Roles] ([RoleId])
    ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE [dbo].[UserRoles] WITH CHECK
    ADD CONSTRAINT [FK_UserRoles_Users_UserId]
    FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId])
    ON DELETE CASCADE ON UPDATE NO ACTION;

-- PlatformSettings (1 FK)
ALTER TABLE [dbo].[PlatformSettings] WITH CHECK
    ADD CONSTRAINT [FK_PlatformSettings_Users_UpdatedByAdminId]
    FOREIGN KEY ([UpdatedByAdminId]) REFERENCES [dbo].[Users] ([UserId])
    ON DELETE SET NULL ON UPDATE NO ACTION;

-- AiUsageLogs (4 FKs)
ALTER TABLE [dbo].[AiUsageLogs] WITH CHECK
    ADD CONSTRAINT [FK_AiUsageLogs_Users_UserId]
    FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE [dbo].[AiUsageLogs] WITH CHECK
    ADD CONSTRAINT [FK_AiUsageLogs_Courses_CourseId]
    FOREIGN KEY ([CourseId]) REFERENCES [dbo].[Courses] ([CourseId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE [dbo].[AiUsageLogs] WITH CHECK
    ADD CONSTRAINT [FK_AiUsageLogs_Lessons_LessonId]
    FOREIGN KEY ([LessonId]) REFERENCES [dbo].[Lessons] ([LessonId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE [dbo].[AiUsageLogs] WITH CHECK
    ADD CONSTRAINT [FK_AiUsageLogs_SupportArticles_SupportArticleId]
    FOREIGN KEY ([SupportArticleId]) REFERENCES [dbo].[SupportArticles] ([ArticleId])
    ON DELETE SET NULL ON UPDATE NO ACTION;

-- Courses (3 FKs)
ALTER TABLE [dbo].[Courses] WITH CHECK
    ADD CONSTRAINT [FK_Courses_Users_InstructorId]
    FOREIGN KEY ([InstructorId]) REFERENCES [dbo].[Users] ([UserId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE [dbo].[Courses] WITH CHECK
    ADD CONSTRAINT [FK_Courses_Categories_CategoryId]
    FOREIGN KEY ([CategoryId]) REFERENCES [dbo].[Categories] ([CategoryId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE [dbo].[Courses] WITH CHECK
    ADD CONSTRAINT [FK_Courses_Users_ReviewedByAdminId]
    FOREIGN KEY ([ReviewedByAdminId]) REFERENCES [dbo].[Users] ([UserId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CourseSections (1 FK)
ALTER TABLE [dbo].[CourseSections] WITH CHECK
    ADD CONSTRAINT [FK_CourseSections_Courses_CourseId]
    FOREIGN KEY ([CourseId]) REFERENCES [dbo].[Courses] ([CourseId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Lessons (1 FK)
ALTER TABLE [dbo].[Lessons] WITH CHECK
    ADD CONSTRAINT [FK_Lessons_CourseSections_SectionId]
    FOREIGN KEY ([SectionId]) REFERENCES [dbo].[CourseSections] ([SectionId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- LessonSummaries (1 FK - 1:0..1 with Lessons)
ALTER TABLE [dbo].[LessonSummaries] WITH CHECK
    ADD CONSTRAINT [FK_LessonSummaries_Lessons_LessonId]
    FOREIGN KEY ([LessonId]) REFERENCES [dbo].[Lessons] ([LessonId])
    ON DELETE CASCADE ON UPDATE NO ACTION;

-- LessonSummaryKeyPoints (1 FK - 1NF multivalued child of LessonSummaries)
ALTER TABLE [dbo].[LessonSummaryKeyPoints] WITH CHECK
    ADD CONSTRAINT [FK_LessonSummaryKeyPoints_LessonSummaries_SummaryId]
    FOREIGN KEY ([SummaryId]) REFERENCES [dbo].[LessonSummaries] ([SummaryId])
    ON DELETE CASCADE ON UPDATE NO ACTION;

-- Enrollments (2 FKs)
ALTER TABLE [dbo].[Enrollments] WITH CHECK
    ADD CONSTRAINT [FK_Enrollments_Users_StudentId]
    FOREIGN KEY ([StudentId]) REFERENCES [dbo].[Users] ([UserId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE [dbo].[Enrollments] WITH CHECK
    ADD CONSTRAINT [FK_Enrollments_Courses_CourseId]
    FOREIGN KEY ([CourseId]) REFERENCES [dbo].[Courses] ([CourseId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Coupons (1 FK)
ALTER TABLE [dbo].[Coupons] WITH CHECK
    ADD CONSTRAINT [FK_Coupons_Courses_CourseId]
    FOREIGN KEY ([CourseId]) REFERENCES [dbo].[Courses] ([CourseId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Payments (4 FKs)
ALTER TABLE [dbo].[Payments] WITH CHECK
    ADD CONSTRAINT [FK_Payments_Users_StudentId]
    FOREIGN KEY ([StudentId]) REFERENCES [dbo].[Users] ([UserId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE [dbo].[Payments] WITH CHECK
    ADD CONSTRAINT [FK_Payments_Courses_CourseId]
    FOREIGN KEY ([CourseId]) REFERENCES [dbo].[Courses] ([CourseId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE [dbo].[Payments] WITH CHECK
    ADD CONSTRAINT [FK_Payments_Enrollments_EnrollmentId]
    FOREIGN KEY ([EnrollmentId]) REFERENCES [dbo].[Enrollments] ([EnrollmentId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE [dbo].[Payments] WITH CHECK
    ADD CONSTRAINT [FK_Payments_Coupons_CouponId]
    FOREIGN KEY ([CouponId]) REFERENCES [dbo].[Coupons] ([CouponId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Certificates (3 FKs)
ALTER TABLE [dbo].[Certificates] WITH CHECK
    ADD CONSTRAINT [FK_Certificates_Enrollments_EnrollmentId]
    FOREIGN KEY ([EnrollmentId]) REFERENCES [dbo].[Enrollments] ([EnrollmentId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE [dbo].[Certificates] WITH CHECK
    ADD CONSTRAINT [FK_Certificates_Users_StudentId]
    FOREIGN KEY ([StudentId]) REFERENCES [dbo].[Users] ([UserId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE [dbo].[Certificates] WITH CHECK
    ADD CONSTRAINT [FK_Certificates_Courses_CourseId]
    FOREIGN KEY ([CourseId]) REFERENCES [dbo].[Courses] ([CourseId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- LessonProgress (2 FKs)
ALTER TABLE [dbo].[LessonProgress] WITH CHECK
    ADD CONSTRAINT [FK_LessonProgress_Enrollments_EnrollmentId]
    FOREIGN KEY ([EnrollmentId]) REFERENCES [dbo].[Enrollments] ([EnrollmentId])
    ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE [dbo].[LessonProgress] WITH CHECK
    ADD CONSTRAINT [FK_LessonProgress_Lessons_LessonId]
    FOREIGN KEY ([LessonId]) REFERENCES [dbo].[Lessons] ([LessonId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Bookmarks (2 FKs)
ALTER TABLE [dbo].[Bookmarks] WITH CHECK
    ADD CONSTRAINT [FK_Bookmarks_Users_StudentId]
    FOREIGN KEY ([StudentId]) REFERENCES [dbo].[Users] ([UserId])
    ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE [dbo].[Bookmarks] WITH CHECK
    ADD CONSTRAINT [FK_Bookmarks_Lessons_LessonId]
    FOREIGN KEY ([LessonId]) REFERENCES [dbo].[Lessons] ([LessonId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- LessonNotes (2 FKs)
ALTER TABLE [dbo].[LessonNotes] WITH CHECK
    ADD CONSTRAINT [FK_LessonNotes_Users_StudentId]
    FOREIGN KEY ([StudentId]) REFERENCES [dbo].[Users] ([UserId])
    ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE [dbo].[LessonNotes] WITH CHECK
    ADD CONSTRAINT [FK_LessonNotes_Lessons_LessonId]
    FOREIGN KEY ([LessonId]) REFERENCES [dbo].[Lessons] ([LessonId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CourseReviews (2 FKs)
ALTER TABLE [dbo].[CourseReviews] WITH CHECK
    ADD CONSTRAINT [FK_CourseReviews_Courses_CourseId]
    FOREIGN KEY ([CourseId]) REFERENCES [dbo].[Courses] ([CourseId])
    ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE [dbo].[CourseReviews] WITH CHECK
    ADD CONSTRAINT [FK_CourseReviews_Users_StudentId]
    FOREIGN KEY ([StudentId]) REFERENCES [dbo].[Users] ([UserId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Quizzes (2 FKs)
ALTER TABLE [dbo].[Quizzes] WITH CHECK
    ADD CONSTRAINT [FK_Quizzes_Courses_CourseId]
    FOREIGN KEY ([CourseId]) REFERENCES [dbo].[Courses] ([CourseId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE [dbo].[Quizzes] WITH CHECK
    ADD CONSTRAINT [FK_Quizzes_CourseSections_SectionId]
    FOREIGN KEY ([SectionId]) REFERENCES [dbo].[CourseSections] ([SectionId])
    ON DELETE SET NULL ON UPDATE NO ACTION;

-- QuizQuestions (1 FK)
ALTER TABLE [dbo].[QuizQuestions] WITH CHECK
    ADD CONSTRAINT [FK_QuizQuestions_Quizzes_QuizId]
    FOREIGN KEY ([QuizId]) REFERENCES [dbo].[Quizzes] ([QuizId])
    ON DELETE CASCADE ON UPDATE NO ACTION;

-- QuestionOptions (1 FK)
ALTER TABLE [dbo].[QuestionOptions] WITH CHECK
    ADD CONSTRAINT [FK_QuestionOptions_QuizQuestions_QuestionId]
    FOREIGN KEY ([QuestionId]) REFERENCES [dbo].[QuizQuestions] ([QuestionId])
    ON DELETE CASCADE ON UPDATE NO ACTION;

-- QuizAttempts (3 FKs)
ALTER TABLE [dbo].[QuizAttempts] WITH CHECK
    ADD CONSTRAINT [FK_QuizAttempts_Quizzes_QuizId]
    FOREIGN KEY ([QuizId]) REFERENCES [dbo].[Quizzes] ([QuizId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE [dbo].[QuizAttempts] WITH CHECK
    ADD CONSTRAINT [FK_QuizAttempts_Users_StudentId]
    FOREIGN KEY ([StudentId]) REFERENCES [dbo].[Users] ([UserId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE [dbo].[QuizAttempts] WITH CHECK
    ADD CONSTRAINT [FK_QuizAttempts_Enrollments_EnrollmentId]
    FOREIGN KEY ([EnrollmentId]) REFERENCES [dbo].[Enrollments] ([EnrollmentId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- QuizAttemptAnswers (3 FKs)
ALTER TABLE [dbo].[QuizAttemptAnswers] WITH CHECK
    ADD CONSTRAINT [FK_QuizAttemptAnswers_QuizAttempts_AttemptId]
    FOREIGN KEY ([AttemptId]) REFERENCES [dbo].[QuizAttempts] ([AttemptId])
    ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE [dbo].[QuizAttemptAnswers] WITH CHECK
    ADD CONSTRAINT [FK_QuizAttemptAnswers_QuizQuestions_QuestionId]
    FOREIGN KEY ([QuestionId]) REFERENCES [dbo].[QuizQuestions] ([QuestionId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE [dbo].[QuizAttemptAnswers] WITH CHECK
    ADD CONSTRAINT [FK_QuizAttemptAnswers_QuestionOptions_SelectedOptionId]
    FOREIGN KEY ([SelectedOptionId]) REFERENCES [dbo].[QuestionOptions] ([OptionId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CourseAnnouncements (2 FKs)
ALTER TABLE [dbo].[CourseAnnouncements] WITH CHECK
    ADD CONSTRAINT [FK_CourseAnnouncements_Courses_CourseId]
    FOREIGN KEY ([CourseId]) REFERENCES [dbo].[Courses] ([CourseId])
    ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE [dbo].[CourseAnnouncements] WITH CHECK
    ADD CONSTRAINT [FK_CourseAnnouncements_Users_InstructorId]
    FOREIGN KEY ([InstructorId]) REFERENCES [dbo].[Users] ([UserId])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Notifications (2 FKs)
ALTER TABLE [dbo].[Notifications] WITH CHECK
    ADD CONSTRAINT [FK_Notifications_Users_RecipientUserId]
    FOREIGN KEY ([RecipientUserId]) REFERENCES [dbo].[Users] ([UserId])
    ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE [dbo].[Notifications] WITH CHECK
    ADD CONSTRAINT [FK_Notifications_CourseAnnouncements_AnnouncementId]
    FOREIGN KEY ([AnnouncementId]) REFERENCES [dbo].[CourseAnnouncements] ([AnnouncementId])
    ON DELETE SET NULL ON UPDATE NO ACTION;
GO

/*==================================================================================================
  SECTION 5: UNIQUE CONSTRAINTS
  Purpose: Enforces all single-column and composite business key uniqueness rules from the approved
           physical schema.
           Note: For NULLable unique columns in [dbo].[Payments] (EnrollmentId,
           StripePaymentIntentId, StripeWebhookEventId), SQL Server filtered unique indexes
           (WHERE column IS NOT NULL) are used so multiple pending/free records with NULL values do
           not collide—matching EF Core's SQL Server migration generator.
==================================================================================================*/

-- Single-Column Unique Constraints (NOT NULL columns)
ALTER TABLE [dbo].[Roles]
    ADD CONSTRAINT [UQ_Roles_RoleName] UNIQUE NONCLUSTERED ([RoleName] ASC);

ALTER TABLE [dbo].[Users]
    ADD CONSTRAINT [UQ_Users_UserName] UNIQUE NONCLUSTERED ([UserName] ASC);

ALTER TABLE [dbo].[Users]
    ADD CONSTRAINT [UQ_Users_Email] UNIQUE NONCLUSTERED ([Email] ASC);

ALTER TABLE [dbo].[PlatformSettings]
    ADD CONSTRAINT [UQ_PlatformSettings_SettingKey] UNIQUE NONCLUSTERED ([SettingKey] ASC);

ALTER TABLE [dbo].[Categories]
    ADD CONSTRAINT [UQ_Categories_Name] UNIQUE NONCLUSTERED ([Name] ASC);

ALTER TABLE [dbo].[Coupons]
    ADD CONSTRAINT [UQ_Coupons_Code] UNIQUE NONCLUSTERED ([Code] ASC);

ALTER TABLE [dbo].[Certificates]
    ADD CONSTRAINT [UQ_Certificates_EnrollmentId] UNIQUE NONCLUSTERED ([EnrollmentId] ASC);

ALTER TABLE [dbo].[Certificates]
    ADD CONSTRAINT [UQ_Certificates_VerificationCode] UNIQUE NONCLUSTERED ([VerificationCode] ASC);

ALTER TABLE [dbo].[LessonSummaries]
    ADD CONSTRAINT [UQ_LessonSummaries_LessonId] UNIQUE NONCLUSTERED ([LessonId] ASC);

-- Composite Unique Constraints ([FK, UQ] pairs in the approved relational schema)
ALTER TABLE [dbo].[Bookmarks]
    ADD CONSTRAINT [UQ_Bookmarks_StudentId_LessonId] UNIQUE NONCLUSTERED ([StudentId] ASC, [LessonId] ASC);

ALTER TABLE [dbo].[CourseReviews]
    ADD CONSTRAINT [UQ_CourseReviews_CourseId_StudentId] UNIQUE NONCLUSTERED ([CourseId] ASC, [StudentId] ASC);

ALTER TABLE [dbo].[Certificates]
    ADD CONSTRAINT [UQ_Certificates_StudentId_CourseId] UNIQUE NONCLUSTERED ([StudentId] ASC, [CourseId] ASC);

ALTER TABLE [dbo].[CourseSections]
    ADD CONSTRAINT [UQ_CourseSections_CourseId_OrderIndex] UNIQUE NONCLUSTERED ([CourseId] ASC, [OrderIndex] ASC);

ALTER TABLE [dbo].[Lessons]
    ADD CONSTRAINT [UQ_Lessons_SectionId_OrderIndex] UNIQUE NONCLUSTERED ([SectionId] ASC, [OrderIndex] ASC);

ALTER TABLE [dbo].[LessonProgress]
    ADD CONSTRAINT [UQ_LessonProgress_EnrollmentId_LessonId] UNIQUE NONCLUSTERED ([EnrollmentId] ASC, [LessonId] ASC);

ALTER TABLE [dbo].[Enrollments]
    ADD CONSTRAINT [UQ_Enrollments_StudentId_CourseId] UNIQUE NONCLUSTERED ([StudentId] ASC, [CourseId] ASC);

ALTER TABLE [dbo].[LessonSummaryKeyPoints]
    ADD CONSTRAINT [UQ_LessonSummaryKeyPoints_SummaryId_OrderIndex] UNIQUE NONCLUSTERED ([SummaryId] ASC, [OrderIndex] ASC);

ALTER TABLE [dbo].[QuizQuestions]
    ADD CONSTRAINT [UQ_QuizQuestions_QuizId_OrderIndex] UNIQUE NONCLUSTERED ([QuizId] ASC, [OrderIndex] ASC);

ALTER TABLE [dbo].[QuestionOptions]
    ADD CONSTRAINT [UQ_QuestionOptions_QuestionId_OrderIndex] UNIQUE NONCLUSTERED ([QuestionId] ASC, [OrderIndex] ASC);

ALTER TABLE [dbo].[QuizAttemptAnswers]
    ADD CONSTRAINT [UQ_QuizAttemptAnswers_AttemptId_QuestionId] UNIQUE NONCLUSTERED ([AttemptId] ASC, [QuestionId] ASC);

-- Filtered Unique Indexes for Nullable Unique Columns on [dbo].[Payments] (0..1 relationships & Stripe IDs)
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Payments_EnrollmentId]
    ON [dbo].[Payments] ([EnrollmentId] ASC)
    WHERE [EnrollmentId] IS NOT NULL;

CREATE UNIQUE NONCLUSTERED INDEX [UQ_Payments_StripePaymentIntentId]
    ON [dbo].[Payments] ([StripePaymentIntentId] ASC)
    WHERE [StripePaymentIntentId] IS NOT NULL;

CREATE UNIQUE NONCLUSTERED INDEX [UQ_Payments_StripeWebhookEventId]
    ON [dbo].[Payments] ([StripeWebhookEventId] ASC)
    WHERE [StripeWebhookEventId] IS NOT NULL;
GO

/*==================================================================================================
  SECTION 6: CHECK CONSTRAINTS
  Purpose: Enforces domain integrity, valid status lifecycles, non-negative monetary/ordering rules,
           and rating bounds (1..5).
==================================================================================================*/

-- Courses domain and pricing checks
ALTER TABLE [dbo].[Courses] WITH CHECK
    ADD CONSTRAINT [CK_Courses_Price_NonNegative]
    CHECK ([Price] >= (0.00) AND ([IsFree] = (0) OR [Price] = (0.00)));

ALTER TABLE [dbo].[Courses] WITH CHECK
    ADD CONSTRAINT [CK_Courses_DifficultyLevel]
    CHECK ([DifficultyLevel] IN ('Beginner', 'Intermediate', 'Advanced', 'AllLevels'));

ALTER TABLE [dbo].[Courses] WITH CHECK
    ADD CONSTRAINT [CK_Courses_Status]
    CHECK ([Status] IN ('Draft', 'PendingApproval', 'Published', 'Rejected', 'Archived'));

ALTER TABLE [dbo].[Courses] WITH CHECK
    ADD CONSTRAINT [CK_Courses_RejectionReason_RequiredWhenRejected]
    CHECK ([Status] <> 'Rejected' OR ([RejectionReason] IS NOT NULL AND LEN(LTRIM(RTRIM([RejectionReason]))) > (0)));

-- CourseReviews 1..5 star rating check (explicitly specified in relational schema)
ALTER TABLE [dbo].[CourseReviews] WITH CHECK
    ADD CONSTRAINT [CK_CourseReviews_Rating_Range]
    CHECK ([Rating] >= (1) AND [Rating] <= (5));

-- CourseSections & Lessons ordering and video metadata checks
ALTER TABLE [dbo].[CourseSections] WITH CHECK
    ADD CONSTRAINT [CK_CourseSections_OrderIndex_Positive]
    CHECK ([OrderIndex] >= (1));

ALTER TABLE [dbo].[Lessons] WITH CHECK
    ADD CONSTRAINT [CK_Lessons_OrderIndex_Positive]
    CHECK ([OrderIndex] >= (1));

ALTER TABLE [dbo].[Lessons] WITH CHECK
    ADD CONSTRAINT [CK_Lessons_VideoMetadata_NonNegative]
    CHECK (([VideoDurationSeconds] IS NULL OR [VideoDurationSeconds] >= (0))
       AND ([VideoSizeBytes] IS NULL OR [VideoSizeBytes] > (0)));

-- LessonNotes timestamp check
ALTER TABLE [dbo].[LessonNotes] WITH CHECK
    ADD CONSTRAINT [CK_LessonNotes_VideoTimestampSeconds_NonNegative]
    CHECK ([VideoTimestampSeconds] IS NULL OR [VideoTimestampSeconds] >= (0));

-- LessonProgress watch position check
ALTER TABLE [dbo].[LessonProgress] WITH CHECK
    ADD CONSTRAINT [CK_LessonProgress_LastWatchedSecond_NonNegative]
    CHECK ([LastWatchedSecond] >= (0));

-- Enrollments status check
ALTER TABLE [dbo].[Enrollments] WITH CHECK
    ADD CONSTRAINT [CK_Enrollments_Status]
    CHECK ([Status] IN ('Active', 'Completed', 'Cancelled', 'Refunded'));

-- Coupons discount checks
ALTER TABLE [dbo].[Coupons] WITH CHECK
    ADD CONSTRAINT [CK_Coupons_DiscountType]
    CHECK ([DiscountType] IN ('Percentage', 'FixedAmount'));

ALTER TABLE [dbo].[Coupons] WITH CHECK
    ADD CONSTRAINT [CK_Coupons_DiscountValue_Valid]
    CHECK ([DiscountValue] > (0.00) AND ([DiscountType] <> 'Percentage' OR [DiscountValue] <= (100.00)));

ALTER TABLE [dbo].[Coupons] WITH CHECK
    ADD CONSTRAINT [CK_Coupons_MaxUsageCount_Positive]
    CHECK ([MaxUsageCount] IS NULL OR [MaxUsageCount] >= (1));

-- Payments financial integrity checks
ALTER TABLE [dbo].[Payments] WITH CHECK
    ADD CONSTRAINT [CK_Payments_Amounts_Integrity]
    CHECK ([OriginalAmount] >= (0.00)
       AND [DiscountAmount] >= (0.00)
       AND [FinalAmount] >= (0.00)
       AND [InstructorEarningsAmount] >= (0.00)
       AND [PlatformFeeAmount] >= (0.00)
       AND [FinalAmount] <= [OriginalAmount]
       AND ([InstructorEarningsAmount] + [PlatformFeeAmount]) = [FinalAmount]);

ALTER TABLE [dbo].[Payments] WITH CHECK
    ADD CONSTRAINT [CK_Payments_PaymentStatus]
    CHECK ([PaymentStatus] IN ('Pending', 'Succeeded', 'Failed', 'Refunded', 'Cancelled'));

-- Quizzes, Questions, Options, and Answers checks
ALTER TABLE [dbo].[Quizzes] WITH CHECK
    ADD CONSTRAINT [CK_Quizzes_PassingScore_Range]
    CHECK ([PassingScore] >= (0.00) AND [PassingScore] <= (100.00));

ALTER TABLE [dbo].[QuizQuestions] WITH CHECK
    ADD CONSTRAINT [CK_QuizQuestions_Points_Positive]
    CHECK ([Points] > (0.00));

ALTER TABLE [dbo].[QuizQuestions] WITH CHECK
    ADD CONSTRAINT [CK_QuizQuestions_OrderIndex_Positive]
    CHECK ([OrderIndex] >= (1));

ALTER TABLE [dbo].[QuestionOptions] WITH CHECK
    ADD CONSTRAINT [CK_QuestionOptions_OrderIndex_Positive]
    CHECK ([OrderIndex] >= (1));

ALTER TABLE [dbo].[QuizAttemptAnswers] WITH CHECK
    ADD CONSTRAINT [CK_QuizAttemptAnswers_AwardedPoints_NonNegative]
    CHECK ([AwardedPoints] >= (0.00));

ALTER TABLE [dbo].[LessonSummaryKeyPoints] WITH CHECK
    ADD CONSTRAINT [CK_LessonSummaryKeyPoints_OrderIndex_Positive]
    CHECK ([OrderIndex] >= (1));
GO

/*==================================================================================================
  SECTION 7: DEFAULT CONSTRAINTS
  Purpose: Applies all explicit column defaults from the approved schema plus UTC timestamp
           defaults (SYSUTCDATETIME()) on audit creation/update columns.
==================================================================================================*/

-- Explicit schema defaults
ALTER TABLE [dbo].[Users]
    ADD CONSTRAINT [DF_Users_IsActive] DEFAULT ((1)) FOR [IsActive];

ALTER TABLE [dbo].[SupportArticles]
    ADD CONSTRAINT [DF_SupportArticles_IsApproved] DEFAULT ((0)) FOR [IsApproved];

ALTER TABLE [dbo].[Notifications]
    ADD CONSTRAINT [DF_Notifications_IsRead] DEFAULT ((0)) FOR [IsRead];

ALTER TABLE [dbo].[Categories]
    ADD CONSTRAINT [DF_Categories_IsActive] DEFAULT ((1)) FOR [IsActive];

ALTER TABLE [dbo].[Courses]
    ADD CONSTRAINT [DF_Courses_Price] DEFAULT ((0.00)) FOR [Price];

ALTER TABLE [dbo].[Courses]
    ADD CONSTRAINT [DF_Courses_IsFree] DEFAULT ((0)) FOR [IsFree];

ALTER TABLE [dbo].[Courses]
    ADD CONSTRAINT [DF_Courses_Status] DEFAULT ('Draft') FOR [Status];

ALTER TABLE [dbo].[Coupons]
    ADD CONSTRAINT [DF_Coupons_IsActive] DEFAULT ((1)) FOR [IsActive];

ALTER TABLE [dbo].[Lessons]
    ADD CONSTRAINT [DF_Lessons_IsRequired] DEFAULT ((1)) FOR [IsRequired];

ALTER TABLE [dbo].[LessonProgress]
    ADD CONSTRAINT [DF_LessonProgress_IsCompleted] DEFAULT ((0)) FOR [IsCompleted];

ALTER TABLE [dbo].[LessonProgress]
    ADD CONSTRAINT [DF_LessonProgress_LastWatchedSecond] DEFAULT ((0)) FOR [LastWatchedSecond];

ALTER TABLE [dbo].[Enrollments]
    ADD CONSTRAINT [DF_Enrollments_Status] DEFAULT ('Active') FOR [Status];

ALTER TABLE [dbo].[Enrollments]
    ADD CONSTRAINT [DF_Enrollments_IsCompleted] DEFAULT ((0)) FOR [IsCompleted];

ALTER TABLE [dbo].[Payments]
    ADD CONSTRAINT [DF_Payments_DiscountAmount] DEFAULT ((0.00)) FOR [DiscountAmount];

ALTER TABLE [dbo].[Payments]
    ADD CONSTRAINT [DF_Payments_Currency] DEFAULT ('USD') FOR [Currency];

ALTER TABLE [dbo].[Payments]
    ADD CONSTRAINT [DF_Payments_PaymentStatus] DEFAULT ('Pending') FOR [PaymentStatus];

ALTER TABLE [dbo].[QuizAttempts]
    ADD CONSTRAINT [DF_QuizAttempts_IsPassed] DEFAULT ((0)) FOR [IsPassed];

ALTER TABLE [dbo].[Quizzes]
    ADD CONSTRAINT [DF_Quizzes_IsRequiredForCertificate] DEFAULT ((1)) FOR [IsRequiredForCertificate];

ALTER TABLE [dbo].[Quizzes]
    ADD CONSTRAINT [DF_Quizzes_IsPublished] DEFAULT ((0)) FOR [IsPublished];

ALTER TABLE [dbo].[QuizQuestions]
    ADD CONSTRAINT [DF_QuizQuestions_Points] DEFAULT ((1.00)) FOR [Points];

ALTER TABLE [dbo].[QuizQuestions]
    ADD CONSTRAINT [DF_QuizQuestions_IsRequired] DEFAULT ((1)) FOR [IsRequired];

ALTER TABLE [dbo].[QuestionOptions]
    ADD CONSTRAINT [DF_QuestionOptions_IsCorrect] DEFAULT ((0)) FOR [IsCorrect];

-- UTC Timestamp defaults for NOT NULL audit columns
ALTER TABLE [dbo].[Roles]
    ADD CONSTRAINT [DF_Roles_CreatedAt] DEFAULT (SYSUTCDATETIME()) FOR [CreatedAt];

ALTER TABLE [dbo].[UserRoles]
    ADD CONSTRAINT [DF_UserRoles_AssignedAt] DEFAULT (SYSUTCDATETIME()) FOR [AssignedAt];

ALTER TABLE [dbo].[Users]
    ADD CONSTRAINT [DF_Users_CreatedAt] DEFAULT (SYSUTCDATETIME()) FOR [CreatedAt];

ALTER TABLE [dbo].[PlatformSettings]
    ADD CONSTRAINT [DF_PlatformSettings_UpdatedAt] DEFAULT (SYSUTCDATETIME()) FOR [UpdatedAt];

ALTER TABLE [dbo].[AiUsageLogs]
    ADD CONSTRAINT [DF_AiUsageLogs_CreatedAt] DEFAULT (SYSUTCDATETIME()) FOR [CreatedAt];

ALTER TABLE [dbo].[SupportArticles]
    ADD CONSTRAINT [DF_SupportArticles_UpdatedAt] DEFAULT (SYSUTCDATETIME()) FOR [UpdatedAt];

ALTER TABLE [dbo].[Notifications]
    ADD CONSTRAINT [DF_Notifications_CreatedAt] DEFAULT (SYSUTCDATETIME()) FOR [CreatedAt];

ALTER TABLE [dbo].[Bookmarks]
    ADD CONSTRAINT [DF_Bookmarks_CreatedAt] DEFAULT (SYSUTCDATETIME()) FOR [CreatedAt];

ALTER TABLE [dbo].[Categories]
    ADD CONSTRAINT [DF_Categories_CreatedAt] DEFAULT (SYSUTCDATETIME()) FOR [CreatedAt];

ALTER TABLE [dbo].[Courses]
    ADD CONSTRAINT [DF_Courses_CreatedAt] DEFAULT (SYSUTCDATETIME()) FOR [CreatedAt];

ALTER TABLE [dbo].[CourseReviews]
    ADD CONSTRAINT [DF_CourseReviews_CreatedAt] DEFAULT (SYSUTCDATETIME()) FOR [CreatedAt];

ALTER TABLE [dbo].[CourseAnnouncements]
    ADD CONSTRAINT [DF_CourseAnnouncements_PublishedAt] DEFAULT (SYSUTCDATETIME()) FOR [PublishedAt];

ALTER TABLE [dbo].[Coupons]
    ADD CONSTRAINT [DF_Coupons_CreatedAt] DEFAULT (SYSUTCDATETIME()) FOR [CreatedAt];

ALTER TABLE [dbo].[Certificates]
    ADD CONSTRAINT [DF_Certificates_IssuedAt] DEFAULT (SYSUTCDATETIME()) FOR [IssuedAt];

ALTER TABLE [dbo].[LessonNotes]
    ADD CONSTRAINT [DF_LessonNotes_CreatedAt] DEFAULT (SYSUTCDATETIME()) FOR [CreatedAt];

ALTER TABLE [dbo].[CourseSections]
    ADD CONSTRAINT [DF_CourseSections_CreatedAt] DEFAULT (SYSUTCDATETIME()) FOR [CreatedAt];

ALTER TABLE [dbo].[Lessons]
    ADD CONSTRAINT [DF_Lessons_CreatedAt] DEFAULT (SYSUTCDATETIME()) FOR [CreatedAt];

ALTER TABLE [dbo].[LessonProgress]
    ADD CONSTRAINT [DF_LessonProgress_UpdatedAt] DEFAULT (SYSUTCDATETIME()) FOR [UpdatedAt];

ALTER TABLE [dbo].[Enrollments]
    ADD CONSTRAINT [DF_Enrollments_EnrolledAt] DEFAULT (SYSUTCDATETIME()) FOR [EnrolledAt];

ALTER TABLE [dbo].[QuizAttempts]
    ADD CONSTRAINT [DF_QuizAttempts_SubmittedAt] DEFAULT (SYSUTCDATETIME()) FOR [SubmittedAt];

ALTER TABLE [dbo].[LessonSummaries]
    ADD CONSTRAINT [DF_LessonSummaries_GeneratedAt] DEFAULT (SYSUTCDATETIME()) FOR [GeneratedAt];

ALTER TABLE [dbo].[Quizzes]
    ADD CONSTRAINT [DF_Quizzes_CreatedAt] DEFAULT (SYSUTCDATETIME()) FOR [CreatedAt];
GO

/*==================================================================================================
  SECTION 8: INDEXES AND PERFORMANCE
  Purpose: Creates targeted nonclustered indexes on Foreign Key columns, course catalog search/filter
           columns, enrollment lookups, notification feeds, Stripe checkout references, and AI rate
           limiting queries without duplicating indexes already created by PK/UQ constraints.
==================================================================================================*/

-- UserRoles: RoleId lookup (UserId is already leading column of PK_UserRoles)
CREATE NONCLUSTERED INDEX [IX_UserRoles_RoleId]
    ON [dbo].[UserRoles] ([RoleId] ASC);

-- PlatformSettings: Admin FK lookup
CREATE NONCLUSTERED INDEX [IX_PlatformSettings_UpdatedByAdminId]
    ON [dbo].[PlatformSettings] ([UpdatedByAdminId] ASC)
    WHERE [UpdatedByAdminId] IS NOT NULL;

-- Courses: Catalog search, filtering, and sorting (Status, CategoryId, Price, DifficultyLevel, Title)
CREATE NONCLUSTERED INDEX [IX_Courses_CatalogFilter]
    ON [dbo].[Courses] ([Status] ASC, [CategoryId] ASC, [DifficultyLevel] ASC, [Price] ASC)
    INCLUDE ([Title], [InstructorId], [IsFree], [ThumbnailUrl], [PublishedAt]);

CREATE NONCLUSTERED INDEX [IX_Courses_Title]
    ON [dbo].[Courses] ([Title] ASC);

CREATE NONCLUSTERED INDEX [IX_Courses_InstructorId]
    ON [dbo].[Courses] ([InstructorId] ASC);

CREATE NONCLUSTERED INDEX [IX_Courses_ReviewedByAdminId]
    ON [dbo].[Courses] ([ReviewedByAdminId] ASC)
    WHERE [ReviewedByAdminId] IS NOT NULL;

-- Enrollments: Reverse lookup by CourseId (StudentId is leading column of UQ_Enrollments_StudentId_CourseId)
CREATE NONCLUSTERED INDEX [IX_Enrollments_CourseId_Status]
    ON [dbo].[Enrollments] ([CourseId] ASC, [Status] ASC)
    INCLUDE ([StudentId], [IsCompleted], [EnrolledAt], [CompletedAt]);

-- LessonProgress: Lookup by LessonId (EnrollmentId is leading column of UQ_LessonProgress_EnrollmentId_LessonId)
CREATE NONCLUSTERED INDEX [IX_LessonProgress_LessonId]
    ON [dbo].[LessonProgress] ([LessonId] ASC);

-- Bookmarks: Lookup by LessonId (StudentId is leading column of UQ_Bookmarks_StudentId_LessonId)
CREATE NONCLUSTERED INDEX [IX_Bookmarks_LessonId]
    ON [dbo].[Bookmarks] ([LessonId] ASC);

-- LessonNotes: Student + Lesson study notes retrieval ordered by timestamp
CREATE NONCLUSTERED INDEX [IX_LessonNotes_StudentId_LessonId]
    ON [dbo].[LessonNotes] ([StudentId] ASC, [LessonId] ASC)
    INCLUDE ([VideoTimestampSeconds], [CreatedAt]);

CREATE NONCLUSTERED INDEX [IX_LessonNotes_LessonId]
    ON [dbo].[LessonNotes] ([LessonId] ASC);

-- CourseReviews: Lookup by StudentId (CourseId is leading column of UQ_CourseReviews_CourseId_StudentId)
CREATE NONCLUSTERED INDEX [IX_CourseReviews_StudentId]
    ON [dbo].[CourseReviews] ([StudentId] ASC);

-- CourseAnnouncements: Course feed ordered by PublishedAt
CREATE NONCLUSTERED INDEX [IX_CourseAnnouncements_CourseId_PublishedAt]
    ON [dbo].[CourseAnnouncements] ([CourseId] ASC, [PublishedAt] DESC);

CREATE NONCLUSTERED INDEX [IX_CourseAnnouncements_InstructorId]
    ON [dbo].[CourseAnnouncements] ([InstructorId] ASC);

-- Notifications: Unread/read inbox lookup per user ordered by CreatedAt
CREATE NONCLUSTERED INDEX [IX_Notifications_RecipientUserId_IsRead_CreatedAt]
    ON [dbo].[Notifications] ([RecipientUserId] ASC, [IsRead] ASC, [CreatedAt] DESC);

CREATE NONCLUSTERED INDEX [IX_Notifications_AnnouncementId]
    ON [dbo].[Notifications] ([AnnouncementId] ASC)
    WHERE [AnnouncementId] IS NOT NULL;

-- Coupons: Course-specific coupon lookup
CREATE NONCLUSTERED INDEX [IX_Coupons_CourseId]
    ON [dbo].[Coupons] ([CourseId] ASC)
    WHERE [CourseId] IS NOT NULL;

-- Payments: Student, Course, Coupon, and StripeSessionId lookups
CREATE NONCLUSTERED INDEX [IX_Payments_StudentId_PaymentStatus]
    ON [dbo].[Payments] ([StudentId] ASC, [PaymentStatus] ASC)
    INCLUDE ([CourseId], [FinalAmount], [PaidAt]);

CREATE NONCLUSTERED INDEX [IX_Payments_CourseId_PaymentStatus]
    ON [dbo].[Payments] ([CourseId] ASC, [PaymentStatus] ASC)
    INCLUDE ([FinalAmount], [InstructorEarningsAmount], [PlatformFeeAmount], [PaidAt]);

CREATE NONCLUSTERED INDEX [IX_Payments_CouponId]
    ON [dbo].[Payments] ([CouponId] ASC)
    WHERE [CouponId] IS NOT NULL;

CREATE NONCLUSTERED INDEX [IX_Payments_StripeSessionId]
    ON [dbo].[Payments] ([StripeSessionId] ASC);

-- Certificates: Lookup by CourseId (EnrollmentId and StudentId+CourseId already have unique indexes)
CREATE NONCLUSTERED INDEX [IX_Certificates_CourseId]
    ON [dbo].[Certificates] ([CourseId] ASC);

-- Quizzes & Assessments: FK and student attempt lookups
CREATE NONCLUSTERED INDEX [IX_Quizzes_CourseId_IsPublished]
    ON [dbo].[Quizzes] ([CourseId] ASC, [IsPublished] ASC);

CREATE NONCLUSTERED INDEX [IX_Quizzes_SectionId]
    ON [dbo].[Quizzes] ([SectionId] ASC)
    WHERE [SectionId] IS NOT NULL;

CREATE NONCLUSTERED INDEX [IX_QuizAttempts_QuizId_StudentId]
    ON [dbo].[QuizAttempts] ([QuizId] ASC, [StudentId] ASC)
    INCLUDE ([EnrollmentId], [IsPassed], [SubmittedAt]);

CREATE NONCLUSTERED INDEX [IX_QuizAttempts_StudentId]
    ON [dbo].[QuizAttempts] ([StudentId] ASC);

CREATE NONCLUSTERED INDEX [IX_QuizAttempts_EnrollmentId]
    ON [dbo].[QuizAttempts] ([EnrollmentId] ASC);

CREATE NONCLUSTERED INDEX [IX_QuizAttemptAnswers_QuestionId]
    ON [dbo].[QuizAttemptAnswers] ([QuestionId] ASC);

CREATE NONCLUSTERED INDEX [IX_QuizAttemptAnswers_SelectedOptionId]
    ON [dbo].[QuizAttemptAnswers] ([SelectedOptionId] ASC);

-- SupportArticles: Topic lookup for approved AI support grounding articles
CREATE NONCLUSTERED INDEX [IX_SupportArticles_IsApproved_TopicCategory]
    ON [dbo].[SupportArticles] ([IsApproved] ASC, [TopicCategory] ASC);

-- AiUsageLogs: Rate-limiting and usage analytics lookups
CREATE NONCLUSTERED INDEX [IX_AiUsageLogs_ClientIdentifier_FeatureType_CreatedAt]
    ON [dbo].[AiUsageLogs] ([ClientIdentifier] ASC, [FeatureType] ASC, [CreatedAt] DESC);

CREATE NONCLUSTERED INDEX [IX_AiUsageLogs_UserId_CreatedAt]
    ON [dbo].[AiUsageLogs] ([UserId] ASC, [CreatedAt] DESC)
    WHERE [UserId] IS NOT NULL;

CREATE NONCLUSTERED INDEX [IX_AiUsageLogs_CourseId]
    ON [dbo].[AiUsageLogs] ([CourseId] ASC)
    WHERE [CourseId] IS NOT NULL;

CREATE NONCLUSTERED INDEX [IX_AiUsageLogs_LessonId]
    ON [dbo].[AiUsageLogs] ([LessonId] ASC)
    WHERE [LessonId] IS NOT NULL;

CREATE NONCLUSTERED INDEX [IX_AiUsageLogs_SupportArticleId]
    ON [dbo].[AiUsageLogs] ([SupportArticleId] ASC)
    WHERE [SupportArticleId] IS NOT NULL;
GO

/*==================================================================================================
  SECTION 9: OPTIONAL INITIAL LOOKUP DATA
  Purpose: Seeds only the mandatory system authorization roles required by FR-1 (Student, Instructor,
           Admin) and baseline platform configuration keys in [dbo].[PlatformSettings] (FR-14, NFR-8).
           No fake users, courses, or business transactions are inserted.
==================================================================================================*/

-- Seed core authorization roles (FR-1) idempotently
MERGE INTO [dbo].[Roles] AS Target
USING (VALUES
    (N'Admin',      N'Platform administrator with permissions to review courses, manage users/categories, and configure platform settings.'),
    (N'Instructor', N'Course creator authorized to build courses, upload videos to Azure Blob Storage, manage quizzes, and view own-course analytics.'),
    (N'Student',    N'Learner authorized to enroll in courses, stream lesson videos, track progress, take quizzes, and earn completion certificates.')
) AS Source ([RoleName], [Description])
ON Target.[RoleName] = Source.[RoleName]
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([RoleName], [Description], [CreatedAt])
    VALUES (Source.[RoleName], Source.[Description], SYSUTCDATETIME());
GO

-- Seed baseline platform governance settings (FR-14, NFR-8) idempotently
MERGE INTO [dbo].[PlatformSettings] AS Target
USING (VALUES
    ('PlatformFeePercentage',        N'20.00', 'Decimal', N'Default platform commission percentage deducted from paid course purchases.'),
    ('AiDailyRequestLimitPerUser',   N'50',    'Integer', N'Maximum AI Assistant / Summarization / Support requests permitted per user or client per 24 hours.'),
    ('MaxVideoUploadSizeBytes',      N'524288000', 'Long', N'Maximum allowed single lesson video upload size in bytes (500 MB default).'),
    ('AllowedVideoFormats',          N'mp4,webm,mov', 'String', N'Comma-separated list of supported video container formats for Azure Blob uploads.')
) AS Source ([SettingKey], [SettingValue], [DataType], [Description])
ON Target.[SettingKey] = Source.[SettingKey]
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([UpdatedByAdminId], [SettingKey], [SettingValue], [DataType], [Description], [UpdatedAt])
    VALUES (NULL, Source.[SettingKey], Source.[SettingValue], Source.[DataType], Source.[Description], SYSUTCDATETIME());
GO